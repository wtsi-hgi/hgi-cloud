import invoke
import glob
import os
import os.path
import sys

def iac_path(context):
  path = 'terraform/modules/openstack/deployments/{}'
  return path.format(context.config['object']['name'])

def var_files(context):
  order = [
    context.config['meta']['release'],
    context.config['meta']['programme'],
    context.config['meta']['env'],
    context.config['object']['name'],
    context.config['object']['version']
  ]
  basename = os.path.join('terraform', 'vars', 'openstack')
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
      context.config['meta']['release'],
      context.config['meta']['programme'],
      context.config['meta']['env'],
      context.config['object']['name'],
      context.config['object']['version']),
    'tfstate'
  ]

def tfplan_file(context, to):
  return [
    os.path.join(
      'terraform', 'deployments',
      context.config['meta']['release'],
      context.config['meta']['programme'],
      context.config['meta']['env'],
      context.config['object']['name'],
      context.config['object']['version']),
    '{}.tfplan'.format(to)
  ]

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
  context.run('terraform init {} {}'.format(options, iac_path(context)))

@invoke.task(init)
def validate(context):
  options = ' '.join(['-var-file={}'.format(f) for f in var_files(context)])
  context.run('terraform validate {} {}'.format(options, iac_path(context)))

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

  context.run('terraform plan {} {}'.format(' '.join(options), iac_path(context)))

def apply_plan(context, to=None):
  tfplan = os.path.join(*tfplan_file(context, to))
  _state_out = '-state-out={}'.format(os.path.join(*tfstate_file(context)))

  if os.path.isfile(tfplan):
    context.run('terraform apply {} {}'.format(_state_out, tfplan))
  else:
    error = (
      '{} does not exist or is not a regular file. '
      'You need to willingly create a plan for that.')
    print(error.format(tfplan))
    sys.exit(1)

@invoke.task(pre=[invoke.call(plan, to='create')])
def up(context):
  apply_plan(context, 'create')

# Since both destruction and update are meant to modify an infrastructure, we
# won't run them automatically at this stage.
@invoke.task
def down(context):
  apply_plan(context, 'destroy')

@invoke.task
def update(context):
  apply_plan(context, 'update')

ns = invoke.Collection()
ns.add_task(clean)
ns.add_task(init)
ns.add_task(validate)
ns.add_task(plan)
ns.add_task(up, default=True)
ns.add_task(down)
ns.add_task(update)
