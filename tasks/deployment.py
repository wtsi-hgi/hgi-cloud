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
    context.config['deployment']['name'],
    context.config['deployment']['owner']
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
      context.config['deployment']['name'],
      context.config['deployment']['owner']),
    'tfstate'
  ]

def tfplan_file(context, to):
  return [
    os.path.join(
      'terraform', 'deployments',
      context.config['meta']['datacenter'],
      context.config['meta']['programme'],
      context.config['meta']['env'],
      context.config['deployment']['name'],
      context.config['deployment']['owner']),
    '{}.tfplan'.format(to)
  ]

def run_terraform(context, args):
  env = {
    'TF_VAR_datacenter': context.config['meta']['datacenter'],
    'TF_VAR_programme': context.config['meta']['programme'],
    'TF_VAR_env': context.config['meta']['env'],
    'TF_VAR_deployment_name': context.config['deployment']['name'],
    'TF_VAR_deployment_owner': context.config['deployment']['owner'],
  }
  context.run('terraform {}'.format(args), env=env)

@invoke.task
def clean(context):
  tfplans = os.path.join(*tfplan_file(context, '*'))
  print('Removing {}'.format(tfplans))
  for plan in glob.glob(tfplans):
    os.remove(plan)

@invoke.task(pre=[clean])
def init(context):
  # options = ' '.join(['-var-file={}'.format(f) for f in var_files(context)])
  options = ''
  run_terraform(context, 'init {} {}'.format(options, iac_path(context)))

@invoke.task(init)
def validate(context):
  options = ' '.join(['-var-file={}'.format(f) for f in var_files(context)])
  run_terraform(context, 'validate {} {}'.format(options, iac_path(context)))

@invoke.task(validate)
def plan(context, to='create'):
  _var_file = ['-var-file={}'.format(f) for f in var_files(context)]

  tfplan_dirname, tfplan_basename = tfplan_file(context, to)
  os.makedirs(tfplan_dirname, exist_ok=True)
  _out = '-out={}'.format(os.path.join(tfplan_dirname, tfplan_basename))

  tfstate_dirname, tfstate_basename = tfstate_file(context)
  os.makedirs(tfstate_dirname, exist_ok=True)
  _state = '-state={}'.format(os.path.join(tfstate_dirname, tfstate_basename))

  options = _var_file + [_out, _state]
  if to == 'destroy':
    options.append('-destroy')

  run_terraform(context, 'plan {} {}'.format(' '.join(options), iac_path(context)))

def apply_plan(context, to=None, parallelism=64):
  tfplan = os.path.join(*tfplan_file(context, to))
  _state_out = '-state-out={}'.format(os.path.join(*tfstate_file(context)))
  _parallelism = '-parallelism={}'.format(parallelism)
  if os.path.isfile(tfplan):
    run_terraform(context, 'apply {} {} {}'.format(_parallelism, _state_out, tfplan))
  else:
    error = (
      '{} does not exist or is not a regular file. '
      'You need to willingly create a plan for that.')
    print(error.format(tfplan))
    sys.exit(1)

@invoke.task(pre=[invoke.call(plan, to='create')])
def up(context, parallelism=64):
  apply_plan(context, 'create', parallelism)

# Since both destruction and update are meant to modify an infrastructure, we
# won't run them automatically at this stage.
@invoke.task
def down(context, parallelism=64):
  apply_plan(context, 'destroy', parallelism)

@invoke.task
def update(context, parallelism=64):
  apply_plan(context, 'update', parallelism)

@invoke.task(post=[invoke.call(plan, to='destroy'), down, up])
def rebuild(context, parallelism=64):
  pass

ns = invoke.Collection()
ns.add_task(clean)
ns.add_task(init)
ns.add_task(validate)
ns.add_task(plan)
ns.add_task(up, default=True)
ns.add_task(down)
ns.add_task(update)
ns.add_task(rebuild)