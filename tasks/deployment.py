import invoke
import glob
import os
import os.path
import sys

def iac_path(context):
  path = 'terraform/modules/{}/deployments/{}'
  return path.format(context.config['meta']['provider'],
                     context.config['deployment']['name'])

def var_files(context):
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

# When we'll move to s3 backed state files, this function will be deprecated
def tfstate_file(context):
  return [
    os.path.join(
      'terraform', 'deployments',
      context.config['meta']['datacenter'],
      context.config['meta']['programme'],
      context.config['meta']['env'],
      context.config['deployment']['owner'],
      context.config['deployment']['name']),
    'tfstate'
  ]

def tfplan_file(context, to):
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
  env = {
    'TF_VAR_datacenter': context.config['meta']['datacenter'],
    'TF_VAR_programme': context.config['meta']['programme'],
    'TF_VAR_env': context.config['meta']['env'],
    'TF_VAR_deployment_owner': context.config['deployment']['owner'],
    'TF_VAR_deployment_name': context.config['deployment']['name'],
  }
  context.run('terraform {}'.format(args), env=env)

@invoke.task
def clean(context):
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
    '-backend-config="key={}"'.format(os.path.join(*tfstate_file(context)))
  ])
  run_terraform(context, 'init {} {}'.format(options, iac_path(context)))

@invoke.task(init)
def validate(context):
  options = ' '.join(['-var-file={}'.format(f) for f in var_files(context)])
  run_terraform(context, 'validate -check-variables=false {} {}'.format(options, iac_path(context)))

@invoke.task(validate)
def plan(context, to='create'):
  _var_file = ['-var-file={}'.format(f) for f in var_files(context)]

  tfplan_dirname, tfplan_basename = tfplan_file(context, to)
  os.makedirs(tfplan_dirname, exist_ok=True)
  _out = '-out={}'.format(os.path.join(tfplan_dirname, tfplan_basename))

  options = _var_file + [_out]
  if to == 'destroy':
    options.append('-destroy')

  run_terraform(context, 'plan {} {}'.format(' '.join(options), iac_path(context)))

def apply_plan(context, to):
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
  apply_plan(context, 'create')

@invoke.task(pre=[invoke.call(plan, to='destroy')])
def decommission(context):
  apply_plan(context, 'destroy')

@invoke.task(post=[deploy])
def create(context, name, owner=None, parallelism=64):
  context.config['deployment']['name'] = name
  context.config['deployment']['owner'] = owner or os.environ['OS_USERNAME']
  context.config['terraform']['parallelism'] = parallelism

@invoke.task(post=[decommission])
def destroy(context, name, owner=None, parallelism=64):
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
