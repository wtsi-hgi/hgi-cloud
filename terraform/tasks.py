from invoke import task

@task
def init(context):
  context.run('terraform init -var-file=vars/dev.tfvars')

@task
def validate(context):
  context.run('terraform validate -var-file=vars/dev.tfvars')

@task
def plan(context):
  pass

@task
def apply(context):
  pass
