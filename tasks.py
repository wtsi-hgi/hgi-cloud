from invoke import Collection, task, call
import glob
import os
import os.path
import sys

@task
def terraform_clean(context):
  tfplan = '{}/*.tfplan'.format(context.config['iac_path'])
  for plan in glob.glob(tfplan):
    os.remove(plan)

@task(terraform_clean)
def terraform_init(context):
  tfvars = context.config['terraform_tfvars']
  iac_path = context.config['iac_path']
  context.run('terraform init -var-file={} {}'.format(tfvars, iac_path))

@task(terraform_init)
def terraform_validate(context):
  tfvars = context.config['terraform_tfvars']
  iac_path = context.config['iac_path']
  context.run('terraform validate -var-file={} {}'.format(tfvars, iac_path))

@task(terraform_validate)
def terraform_plan(context, to='create'):
  iac_path = context.config['iac_path']
  options = '-out={}/{}.tfplan'.format(iac_path, to)
  options += ' -destroy' if to == 'destroy' else ''
  tfvars = context.config['terraform_tfvars']
  context.run('terraform plan {} -var-file={} {}'.format(options, tfvars, iac_path))

@task(pre=[call(terraform_plan, to='create')])
def terraform_up(context):
  iac_path = context.config['iac_path']
  context.run('terraform apply {}/{}.tfplan'.format(iac_path, 'create'))

# Since both destruction and update are meant to modify an infrastructure, we
# won't run them automatically at this stage.
@task
def terraform_down(context):
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

@task
def terraform_update(context):
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

terraform = Collection()
terraform.add_task(terraform_clean, name='clean')
terraform.add_task(terraform_init, name='init')
terraform.add_task(terraform_validate, name='validate')
terraform.add_task(terraform_plan, name='plan')
terraform.add_task(terraform_up, name='up', default=True)
terraform.add_task(terraform_down, name='down')
terraform.add_task(terraform_update, name='update')

ns = Collection()
ns.add_collection(terraform, name='terraform')
