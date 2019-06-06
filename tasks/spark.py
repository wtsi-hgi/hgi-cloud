import invoke
import glob
import os
import os.path
import sys

def create_terraform_vars(order):
  dirname = os.path.join('terraform', 'vars')
  created = []

  for name in order:
    os.path.exists(dirname) or os.mkdir(dirname)
    tfvars = os.path.join(dirname, '{}.tfvars'.format(name))
    if not os.path.exists(tfvars):
      with open(tfvars, 'w') as f:
        f.wite("# Automatically generated\n")
        created.append(tfvars)
    dirname = os.path.join(dirname, name)

  return created

def create_ansible_vars(order, masters_roles, slaves_role):
  dirname = os.path.join('ansible', 'vars')
  created = []

  for name in order:
    os.path.exists(dirname) or os.mkdir(dirname)
    yml = os.path.join(dirname, '{}.yml'.format(name))
    if not os.path.exists(yml):
      with open(yml, 'w') as f:
        f.wite("---\n# Automatically generated\n{}\n")
      created.append(yml)
    dirname = os.path.join(dirname, name)

  os.path.exists(dirname) or os.mkdir(dirname)
  for name in (masters_roles, slaves_role):
    yml = os.path.join(dirname, '{}.yml'.format(name))
    if not os.path.exists(yml):
      with open(yml, 'w') as f:
        f.wite("---\n# Automatically generated\n{}\n")
      created.append(yml)

  return created

@invoke.task
def init(context, masters_roles, slaves_role):
  created = []
  order = [
    context.config['meta']['datacenter'],
    context.config['meta']['programme'],
    context.config['meta']['env'],
    context.config['deployment']['owner'],
    context.config['deployment']['name']
  ]
  created += create_terraform_vars(order) + \
             create_ansible_vars(order, masters_roles, slaves_role)

  spark_conf = ['terraform', 'vars'] + order
  user_conf = spark_conf[:]
  spark_conf[-1] = spark_conf[-1] + '.tfvars'
  user_conf[-1] = 'user.tfvars'

  with open(os.path.join(*spark_conf), 'a') as conf:
    conf.write("spark_masters_role_name = \"{}\"\n".format(masters_roles))
    conf.write("spark_slaves_role_name = \"{}\"\n".format(slaves_role))

  print('The following files have been created:')
  for conf in created:
    print('  {}'.format(conf))

  context.run('git add {}'.format(' '.join(created)))

@invoke.task
def deploy(context, full=False):
  owner = context.config['deployment']['owner']
  if full:
    context.run('bash invoke.sh deployment {}/networking up'.format(owner))
  context.run('bash invoke.sh deployment {}/spark up'.format(owner))

@invoke.task
def decommission(context, full=False):
  owner = context.config['deployment']['owner']
  context.run('bash invoke.sh deployment {}/spark down'.format(owner))
  if full:
    context.run('bash invoke.sh deployment {}/networking down'.format(owner))

ns = invoke.Collection()
ns.add_task(init)
ns.add_task(deploy)
ns.add_task(decommission)
