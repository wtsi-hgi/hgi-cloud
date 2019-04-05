import invoke
import glob
import os
import os.path
import sys

def iac_path(context):
  path = 'terraform/modules/openstack/{}s/{}'
  return path.format(context.config['object']['type'],
                     context.config['object']['name'])

def tfvars_path(context):
  path = 'terraform/vars/{}-{}-{}.tfvars'
  return path.format(context.config['meta']['release'],
                     context.config['meta']['programme'],
                     context.config['meta']['env'])

@invoke.task
def clean(context):
  tfplan = '{}/*.tfplan'.format(iac_path(context))
  print('Removing {}'.format(tfplan))
  for plan in glob.glob(tfplan):
    os.remove(plan)

@invoke.task(pre=[clean])
def init(context):
  var_file = tfvars_path(context)
  context.run('terraform init -var-file={} {}'.format(var_file, iac_path(context)))

@invoke.task(init)
def validate(context):
  var_file = tfvars_path(context)
  context.run('terraform validate -var-file={} {}'.format(var_file, iac_path(context)))

@invoke.task(validate)
def plan(context, to='create'):
  var_file = tfvars_path(context)
  tfplan = '{}/{}.tfplan'.format(iac_path(context), to)
  tfstate = '{}/terraform.tfstate'.format(iac_path(context))
  options = '-out={} -state={} -var-file={}'.format(tfplan, tfstate, var_file)
  if to == 'destroy':
    options += ' -destroy'
  context.run('terraform plan {} {}'.format(options, iac_path(context)))
  print('terraform plan created: {}'.format(tfplan))

@invoke.task(pre=[invoke.call(plan, to='create')])
def up(context):
  tfplan = '{}/create.tfplan'.format(iac_path(context))
  tfstate = '{}/terraform.tfstate'.format(iac_path(context))
  options = '-state-out={}'.format(tfstate)
  context.run('terraform apply {} {}'.format(options, tfplan))

# Since both destruction and update are meant to modify an infrastructure, we
# won't run them automatically at this stage.
@invoke.task
def down(context):
  tfplan = '{}/destroy.tfplan'.format(iac_path(context))
  tfstate = '{}/terraform.tfstate'.format(iac_path(context))
  options = '-state-out={}'.format(tfstate)
  if os.path.isfile(tfplan):
    context.run('terraform apply {} {}'.format(options, tfplan))
  else:
    error = (
      '{} does not exist or is not a regular file. '
      'You need to willingly create a plan for destruction')
    print(error.format(tfplan))
    sys.exit(1)

@invoke.task
def update(context):
  tfplan = '{}/update.tfplan'.format(iac_path(context))
  tfstate = '{}/terraform.tfstate'.format(iac_path(context))
  options = '-state-out={}'.format(tfstate)
  if os.path.isfile(tfplan):
    context.run('terraform apply {} {}'.format(options, tfplan))
  else:
    error = (
      '{} does not exist or is not a regular file. '
      'You need to willingly create a plan for the update')
    print(error.format(tfplan))
    sys.exit(1)

ns = invoke.Collection()
ns.add_task(clean)
ns.add_task(init)
ns.add_task(validate)
ns.add_task(plan)
ns.add_task(up, default=True)
ns.add_task(down)
ns.add_task(update)
