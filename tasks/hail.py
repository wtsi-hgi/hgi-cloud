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
        f.write("# Automatically generated\n")
        created.append(tfvars)
    dirname = os.path.join(dirname, name)

  for deployment in ['hail_cluster', 'hail_volume', 'networking']:
    tfvar = os.path.join(dirname, deployment + '.tfvars')
    with open(tfvars, 'w') as f:
      f.write("# Automatically generated\n")
      created.append(tfvars)

  return created

def create_ansible_vars(order):
  dirname = os.path.join('ansible', 'vars')
  created = []

  for name in order:
    if not os.path.exists(dirname):
      os.mkdir(dirname)
    yml = os.path.join(dirname, '{}.yml'.format(name))
    if not os.path.exists(yml):
      with open(yml, 'w') as f:
        f.write("---\n# Automatically generated\n{}\n")
      created.append(yml)
    dirname = os.path.join(dirname, name)

  os.path.exists(dirname) or os.mkdir(dirname)
  for name in ('hail-master', 'hail-slave'):
    yml = os.path.join(dirname, '{}.yml'.format(name))
    if not os.path.exists(yml):
      with open(yml, 'w') as f:
        f.write("---\n# Automatically generated\n{}\n")
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
def init(context, owner=None):
  created = []
  order = [
    context.config['meta']['datacenter'],
    context.config['meta']['programme'],
    context.config['meta']['env'],
    owner or os.environ['OS_USERNAME']
  ]
  created += create_terraform_vars(order) + \
             create_ansible_vars(order)

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
