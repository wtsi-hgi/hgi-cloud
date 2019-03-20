import invoke
import glob
import os
import os.path
import sys

def terraform_tfvars(context):
  env = context.config['env']
  os_release = context.config['os_release']
  return 'terraform/vars/{}-hgi-{}.tfvars'.format(os_release, env)

@invoke.task
def clean(context):
  tfplan = '{}/*.tfplan'.format(context.config['iac_path'])
  print('Removing {}'.format(tfplan))
  for plan in glob.glob(tfplan):
    os.remove(plan)

@invoke.task(pre=[clean])
def init(context):
  var_file = terraform_tfvars(context)
  iac_path = context.config['iac_path']
  context.run('terraform init -var-file={} {}'.format(var_file, iac_path))

@invoke.task(init)
def validate(context):
  var_file = terraform_tfvars(context)
  iac_path = context.config['iac_path']
  context.run('terraform validate -var-file={} {}'.format(var_file, iac_path))

@invoke.task(validate)
def plan(context, to='create'):
  var_file = terraform_tfvars(context)
  iac_path = context.config['iac_path']
  terraform_plan = 'terraform plan {} -var-file={} {}'
  options = '-out={}/{}.tfplan'.format(iac_path, to)
  if to == 'destroy':
    options += ' -destroy'
  context.run(terraform_plan.format(options, var_file, iac_path))

@invoke.task(pre=[invoke.call(plan, to='create')])
def up(context):
  iac_path = context.config['iac_path']
  context.run('terraform apply {}/{}.tfplan'.format(iac_path, 'create'))

# Since both destruction and update are meant to modify an infrastructure, we
# won't run them automatically at this stage.
@invoke.task
def down(context):
  iac_path = context.config['iac_path']
  tfplan = '{}/destroy.tfplan'.format(iac_path)
  if os.path.isfile(tfplan):
    context.run('terraform apply {}'.format(tfplan))
  else:
    error = (
      '{} does not exist or is not a regular file.'
      'You need to willingly create a plan for destruction')
    print(error.format(tfplan))
    sys.exit(1)

@invoke.task
def update(context):
  iac_path = context.config['iac_path']
  tfplan = '{}/update.tfplan'.format(iac_path)
  if os.path.isfile(tfplan):
    context.run('terraform apply {}'.format(tfplan))
  else:
    error = (
      '{} does not exist or is not a regular file.'
      'You need to willingly create a plan for the update')
    print(error.format(tfplan))
    sys.exit(1)
