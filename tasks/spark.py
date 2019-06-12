import invoke
import glob
import os
import os.path
import sys

import openstack as openstack_client

openstack = openstack_client.connect(auth_url=os.environ['OS_AUTH_URL'],
                                     project_name=os.environ['OS_PROJECT_NAME'],
                                     username=os.environ['OS_USERNAME'],
                                     password=os.environ['OS_PASSWORD'],
                                     region_name=os.environ['OS_REGION_NAME'],
                                     app_name='invoke')

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

def jupyter_data_volume(context, owner):
  volume_name = '-'.join([
      context.config['meta']['datacenter'],
      context.config['meta']['programme'],
      context.config['meta']['env'],
      'volume', owner, 'jupyter-data-01'])
  return [ v.id for v in openstack.volume.volumes() if v.name == volume_name][0]

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
def create(context, owner, networking=False):
  if networking:
    context.run('bash invoke.sh deployment create --name networking --owner {}'.format(owner))
  context.run('bash invoke.sh deployment create --name jupyter --owner {}'.format(owner))
  volume_name = '-'.join([
      context.config['meta']['datacenter'],
      context.config['meta']['programme'],
      context.config['meta']['env'],
      'volume', owner, 'jupyter-data-01'])
  env = {
    'TF_VAR_jupyter_data_volume': jupyter_data_volume(context, owner)
  }
  context.run('bash invoke.sh deployment create --name spark --owner {}'.format(owner), env=env)

@invoke.task
def destroy(context, owner, networking=False, yes_also_jupyter_data=False):
  env = {
    'TF_VAR_jupyter_data_volume': jupyter_data_volume(context, owner)
  }
  context.run('bash invoke.sh deployment destroy --name spark --owner {}'.format(owner), env=env)
  if networking:
    context.run('bash invoke.sh deployment destroy --name networking --owner {}'.format(owner))
  if yes_also_jupyter_data:
    context.run('bash invoke.sh deployment destroy --name jupyter --owner {}'.format(owner))

ns = invoke.Collection()
ns.add_task(init)
ns.add_task(create)
ns.add_task(destroy)
