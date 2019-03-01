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
  context.run('terraform init -var-file=vars/dev.tfvars')

@task(init)
def validate(context):
  context.run('terraform validate -var-file=vars/dev.tfvars')

@task(validate)
def plan(context, to='create'):
  out = {
    'create': '-out=creation.tfplan',
    'update': '-out=update.tfplan',
    'destroy': '-destroy -out=destruction.tfplan'
  }
  context.run("terraform plan %s -var-file=vars/dev.tfvars" % out[to])

@task(pre=[call(plan, to='create')])
def create(context):
  pass

# Since both destroy and update are meant to modify an infrastructure, we won't
# run them automatically at this stage.
@task
def destroy(context):
  if os.path.isfile('destroy.tfplan'):
    context.run('terraform apply -plan=destroy.tfplan -var-file=vars/dev.tfvars')
  else:
    print('destroy.tfplan does not exist or is not a regular file.')
    print("Use `invoke plan --to destroy` first")
    sys.exit(1)

@task
def update(context):
  if os.path.isfile('update.tfplan'):
    context.run('terraform apply -plan=update.tfplan -var-file=vars/dev.tfvars')
  else:
    print('update.tfplan does not exist or is not a regular file.')
    print("Use `invoke plan --to update` first")
    sys.exit(1)
