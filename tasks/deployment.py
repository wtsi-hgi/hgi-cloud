'''
This group of tasks deals with the life cycle of any terraform deployment.
'''

import invoke
import glob
import os
import os.path
import sys

def iac_path(context):
  '''
  Returns the path of the deployment code inside this repository.

  :param context: PyInvoke context
  :return: path of the deployment code
  '''
  path = 'terraform/modules/{}/deployments/{}'
  return path.format(context.config['meta']['provider'],
                     context.config['deployment']['name'])

def var_files(context):
  '''
  Returns the list of the terraform variables files.

  :param context: PyInvoke context
  :return: the list of the terraform variables files
  '''
  order = [
    context.config['meta']['datacenter'],
    context.config['meta']['programme'],
    context.config['meta']['env'],
    context.config['deployment']['owner'],
    context.config['deployment']['name']
  ]
  basename = os.path.join('terraform', 'vars')
  paths = []
  for path in order:
    basename = os.path.join(basename, path)
    paths.append('{}.tfvars'.format(basename))
  return paths

def tfplan_file(context, to):
  '''
  Returns the `tfplan` the direcotry path and the filename associated witht the
  desired operation.

  :param context: PyInvoke context
  :param to: What the plan is about: either `create`, `destroy` or `update`
  :return: tfplan directory path and the filename
  '''
  return [
    os.path.join(
      'terraform', 'deployments',
      context.config['meta']['datacenter'],
      context.config['meta']['programme'],
      context.config['meta']['env'],
      context.config['deployment']['owner'],
      context.config['deployment']['name']),
    '{}.tfplan'.format(to)
  ]

def run_terraform(context, args):
  '''
  Prepares the environment variables and then runs the terraform command to
  carry out the desired operation.

  :param context: PyInvoke context
  :param args: a string with all the terraform command arguments
  '''
  env = {
    'TF_VAR_datacenter': context.config['meta']['datacenter'],
    'TF_VAR_programme': context.config['meta']['programme'],
    'TF_VAR_env': context.config['meta']['env'],
    'TF_VAR_deployment_owner': context.config['deployment']['owner'],
    'TF_VAR_deployment_name': context.config['deployment']['name'],
    'TF_VAR_aws_access_key_id': os.environ['AWS_ACCESS_KEY_ID'],
    'TF_VAR_aws_secret_access_key': os.environ['AWS_SECRET_ACCESS_KEY'],
    'TF_VAR_aws_s3_endpoint': os.environ['AWS_S3_ENDPOINT'],
    'TF_VAR_aws_default_region': os.environ['AWS_DEFAULT_REGION']
  }
  context.run('terraform {}'.format(args), env=env)

@invoke.task
def clean(context):
  '''
  Removes all `tfstate` and `tfplan` files.
  '''
  tfplans = os.path.join(*tfplan_file(context, '*'))
  tfstate = os.path.join('.terraform', 'terraform.tfstate')
  print('Removing {}'.format(tfplans))
  for plan in glob.glob(tfplans):
    os.remove(plan)
  print('Removing {}'.format(tfstate))
  if os.path.exists(tfstate):
    os.remove(tfstate)

@invoke.task(pre=[clean])
def init(context):
  '''
  Runs `terraform init` which also configures the remote state backend.

  :param context: PyInvoke context
  '''
  tfstate = os.path.join('terraform', 'deployments',
                         context.config['meta']['datacenter'],
                         context.config['meta']['programme'],
                         context.config['meta']['env'],
                         context.config['deployment']['owner'],
                         context.config['deployment']['name'],
                         'tfstate')
  bucket = '-'.join([
    context.config['meta']['datacenter'],
    context.config['meta']['programme'],
    'bucket',
    os.environ['OS_USERNAME']
  ])
  options = ' '.join([
    '-backend-config="region=eu-west-1"',
    '-backend-config="skip_credentials_validation=true"',
    '-backend-config="bucket={}"'.format(bucket),
    '-backend-config="key={}"'.format(tfstate)
  ])
  run_terraform(context, 'init {} {}'.format(options, iac_path(context)))

@invoke.task(init)
def validate(context):
  '''
  Runs `terraform validate` on the specified provisioning module.

  :param context: PyInvoke context
  '''
  options = ' '.join(['-var-file={}'.format(f) for f in var_files(context)])
  run_terraform(context, 'validate -check-variables=false {} {}'.format(options, iac_path(context)))

@invoke.task(validate)
def plan(context, to='create'):
  '''
  Runs `terraform plan`. Different plans can be created..

  :param context: PyInvoke context
  :param to: What the plan is about: either `create`, `destroy` or `update`
  '''
  _var_file = ['-var-file={}'.format(f) for f in var_files(context)]

  tfplan_dirname, tfplan_basename = tfplan_file(context, to)
  os.makedirs(tfplan_dirname, exist_ok=True)
  _out = '-out={}'.format(os.path.join(tfplan_dirname, tfplan_basename))

  options = _var_file + [_out]
  if to == 'destroy':
    options.append('-destroy')

  run_terraform(context, 'plan {} {}'.format(' '.join(options), iac_path(context)))

def apply_plan(context, to):
  '''
  Applies a previously generated plan (with `terraform plan`).

  :param context: PyInvoke context
  :param to: What the plan is about: either `create`, `destroy` or `update`
  '''
  tfplan = os.path.join(*tfplan_file(context, to))
  _parallelism = '-parallelism={}'.format(context.config['terraform']['parallelism'])
  if os.path.isfile(tfplan):
    run_terraform(context, 'apply {} {}'.format(_parallelism, tfplan))
  else:
    error = (
      '{} does not exist or is not a regular file. '
      'You need to willingly create a plan for that.')
    print(error.format(tfplan))
    sys.exit(1)

@invoke.task(pre=[invoke.call(plan, to='create')])
def deploy(context):
  '''
  Applies the plan to create a piece of infrastructure.

  :param context: PyInvoke context
  '''
  apply_plan(context, 'create')

@invoke.task(pre=[invoke.call(plan, to='destroy')])
def decommission(context):
  '''
  Applies the plan to destroy a piece of infrastructure.

  :param context: PyInvoke context
  '''
  apply_plan(context, 'destroy')

@invoke.task(post=[deploy])
def create(context, name, owner=None, parallelism=64):
  '''
  Front-end task that prepares the context for the `deploy` task.

  :param context: PyInvoke context
  :param name: name of the deployment to be created
  :param owner: the name of the owner of the deployment. Defaults to current user
  :param parallelism: the number of objects to be concurrently created
  '''
  context.config['deployment']['name'] = name
  context.config['deployment']['owner'] = owner or os.environ['OS_USERNAME']
  context.config['terraform']['parallelism'] = parallelism

@invoke.task(post=[decommission])
def destroy(context, name, owner=None, parallelism=64):
  '''
  Front-end task that prepares the context for the `decommission` task.

  :param context: PyInvoke context
  :param name: name of the deployment to be destroyed
  :param owner: the name of the owner of the deployment. Defaults to current user
  :param parallelism: the number of objects to be concurrently destroyed
  '''
  context.config['deployment']['name'] = name
  context.config['deployment']['owner'] = owner or os.environ['OS_USERNAME']
  context.config['terraform']['parallelism'] = parallelism

ns = invoke.Collection()
ns.add_task(clean)
ns.add_task(init)
ns.add_task(validate)
ns.add_task(plan)
ns.add_task(deploy)
ns.add_task(decommission)
ns.add_task(create, default=True)
ns.add_task(destroy)
