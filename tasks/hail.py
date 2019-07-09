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
    if not os.path.exists(dirname): 
      os.mkdir(dirname)
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
    if not os.path.exists(dirname):
      os.mkdir(dirname)
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

def get_hail_volume_name(context, owner):
  volume_name = '-'.join([
      context.config['meta']['datacenter'],
      context.config['meta']['programme'],
      context.config['meta']['env'],
      'volume', owner, 'hail-data-01'])
  return [ v.id for v in openstack.volume.volumes() if v.name == volume_name][0]

@invoke.task
def init(context, owner=None, masters_roles='hail-master', slaves_role='hail-slave'):
  created = []
  order = [
    context.config['meta']['datacenter'],
    context.config['meta']['programme'],
    context.config['meta']['env'],
    owner or os.environ['OS_USERNAME'],
    context.config['deployment']['name']
  ]
  created += create_terraform_vars(order) + \
             create_ansible_vars(order, masters_roles, slaves_role)

  hail_cluster_conf = ['terraform', 'vars'] + order
  hail_cluster_conf[-1] = hail_cluster_conf[-1] + '.tfvars'

  with open(os.path.join(*hail_cluster_conf), 'a') as conf:
    conf.write("spark_masters_role_name = \"{}\"\n".format(masters_roles))
    conf.write("spark_slaves_role_name = \"{}\"\n".format(slaves_role))

  print('The following files have been created:')
  for conf in created:
    print('  {}'.format(conf))

  # context.run('git add {}'.format(' '.join(created)))

@invoke.task
def create(context, owner=None, networking=False):
  owner = owner or os.environ['OS_USERNAME']
  if networking:
    context.run('bash invoke.sh deployment create --name networking --owner {}'.format(owner))
  context.run('bash invoke.sh deployment create --name hail_volume --owner {}'.format(owner))
  env = {
    'TF_VAR_hail_volume': get_hail_volume_name(context, owner)
  }
  context.run('bash invoke.sh deployment create --name hail_cluster --owner {}'.format(owner), env=env)

@invoke.task
def destroy(context, owner=None, networking=False, yes_also_hail_volume=False):
  owner = owner or os.environ['OS_USERNAME']
  env = {
    'TF_VAR_hail_volume': get_hail_volume_name(context, owner)
  }
  context.run('bash invoke.sh deployment destroy --name hail_cluster --owner {}'.format(owner), env=env)
  if networking:
    context.run('bash invoke.sh deployment destroy --name networking --owner {}'.format(owner))
  if yes_also_hail_volume:
    context.run('bash invoke.sh deployment destroy --name hail_volume --owner {}'.format(owner))

ns = invoke.Collection()
ns.add_task(init)
ns.add_task(create)
ns.add_task(destroy)
