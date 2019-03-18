from invoke import task, call
import glob
import os
import os.path
import sys

@task
def clean(context):
  for plan in glob.glob('*.tfplan'):
    os.remove(plan)

@task(clean)
def init(context):
  tfvars = context.config.get('terraform_tfvars', 'vars/dev.tfvars')
  with context.cd(context.config.get('terraform_path', '.')):
    context.run('terraform init -var-file={}'.format(tfvars))

@task(init)
def validate(context):
  tfvars = context.config.get('terraform_tfvars', 'vars/dev.tfvars')
  with context.cd(context.config.get('terraform_path', '.')):
    context.run('terraform validate -var-file={}'.format(tfvars))

@task(validate)
def plan(context, to='create'):
  out = {
    'create': '-out=creation.tfplan',
    'update': '-out=update.tfplan',
    'destroy': '-destroy -out=destruction.tfplan'
  }
  tfvars = context.config.get('terraform_tfvars', 'vars/dev.tfvars')
  with context.cd(context.config.get('terraform_path', '.')):
    context.run('terraform plan {} -var-file={}'.format(out[to], tfvars))

@task(pre=[call(plan, to='create')])
def creation(context):
  with context.cd(context.config.get('terraform_path', '.')):
    context.run('terraform apply creation.tfplan')

# Since both destruction and update are meant to modify an infrastructure, we
# won't run them automatically at this stage.
@task
def destruction(context):
  terraform_path = context.config.get('terraform_path', '.')
  tfplan = '{}/destruction.tfplan'.format(terraform_path)
  if os.path.isfile(tfplan):
    with context.cd(terraform_path):
      context.run('terraform apply destruction.tfplan')
  else:
    error = (
      '{} does not exist or is not a regular file.'
      'Run `pushd {} ; invoke plan --to destroy ; popd` first')
    print(error.format(tfplan, terraform_path))
    sys.exit(1)

@task
def update(context):
  terraform_path = context.config.get('terraform_path', '.')
  tfplan = '{}/update.tfplan'.format(terraform_path)
  if os.path.isfile(tfplan):
    with context.cd(terraform_path):
      context.run('terraform apply update.tfplan')
  else:
    error = (
      '{} does not exist or is not a regular file.'
      'Run `pushd {} ; invoke plan --to update ; popd` first')
    print(error.format(tfplan, terraform_path))
    sys.exit(1)
