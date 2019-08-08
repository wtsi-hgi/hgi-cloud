'''
This group of tasks deals with high level operations on an Hail cluster.
'''
import invoke
import glob
import os
import os.path
import sys
import urllib3

import infoblox_client.connector
import infoblox_client.objects
import openstack as openstack_client

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

def create_terraform_vars(order, public_ip, network_cidr, volume_size):
  '''
  Creates and configures terraform input variables files

  :param list order: the list of sub-directories where the `tfvars` files are
  :param public_ip: the `public` network IP to associate to the cluster
  :param network_cidr: the network CIDR to use for stand-alone isoleted
                       Hail clusters
  :param volume_size: the size of the extra volume for Hail's `tmp_dir`
  '''
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

  if not os.path.exists(dirname):
    os.mkdir(dirname)

  tfvars = os.path.join(dirname, 'hail_cluster.tfvars')
  if not os.path.exists(tfvars):
    with open(tfvars, 'w') as conf:
      conf.write('spark_master_external_address = "{}"\n'.format(public_ip))
    created.append(tfvars)
  else:
    print('Skipping {}: it already exists'.format(tfvars))

  tfvars = os.path.join(dirname, 'networking.tfvars')
  if network_cidr and not os.path.exist(tfvars):
    with open(tfvars, 'w') as conf:
      conf.write('main_subnet_cidr = "{}"\n'.format(network_cidr))
    created.append(tfvars)
  else:
    print('Skipping {}: it already exists'.format(tfvars))

  TFVARS = os.path.join(dirname, 'hail_volume.tfvars')
  if volume_size and not os.path.exist(tfvars):
    with open(tfvars, 'w') as conf:
      conf.write('hail_volume_size = "{}"\n'.format(volume_size))
    created.append(tfvars)
  else:
    print('Skipping {}: it already exists'.format(tfvars))

  return created

def create_ansible_vars(order):
  '''
  Creates and configures Ansible's extra variables files

  :param list order: the list of sub-directories where the `tfvars` files are
  '''
  dirname = os.path.join('ansible', 'vars')
  created = []

  for name in order + ['hail']:
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
  '''
  Returns the name of the Hail's persistent volume, based on the context.

  :param context: PyInvoke context
  :param owner: the name of the user
  :return: the name of the volume or `None`
  '''
  openstack = openstack_client.connect(auth_url=os.environ['OS_AUTH_URL'],
                                       project_name=os.environ['OS_PROJECT_NAME'],
                                       username=os.environ['OS_USERNAME'],
                                       password=os.environ['OS_PASSWORD'],
                                       region_name=os.environ['OS_REGION_NAME'],
                                       app_name='invoke')
  volume_name = '-'.join([
      context.config['meta']['datacenter'],
      context.config['meta']['programme'],
      context.config['meta']['env'],
      'volume', owner, 'hail-data-01'])

  volumes = [v.id for v in openstack.volume.volumes() if v.name == volume_name]
  return volumes[0] if volumes else None


def get_openstack_flavours():
  # Quick-and-dirty function that serialises the OpenStack flavours into
  # a Terraform variable
  openstack = openstack_client.connect(auth_url=os.environ['OS_AUTH_URL'],
                                       project_name=os.environ['OS_PROJECT_NAME'],
                                       username=os.environ['OS_USERNAME'],
                                       password=os.environ['OS_PASSWORD'],
                                       region_name=os.environ['OS_REGION_NAME'],
                                       app_name='invoke')

  return "[{}]".format(
    ", ".join(
      f"{{name = \"{flavour.name}\", ram = {flavour.ram}, cpus = {flavour.vcpus}}}"
      for flavour in openstack.list_flavors()
    )
  )


@invoke.task
def init(context, public_ip, network_cidr=None, volume_size=None, owner=None):
  '''
  Initialises an Hail cluster configuration

  :param list order: the list of sub-directories where the `tfvars` files are
  :param public_ip: the `public` network IP to associate to the cluster
  :param network_cidr: the network CIDR to use for stand-alone isoleted
                       Hail clusters
  :param volume_size: the size of the extra volume for Hail's `tmp_dir`
  :param owner: the name of the user
  '''
  order = [
    context.config['meta']['datacenter'],
    context.config['meta']['programme'],
    context.config['meta']['env'],
    owner or os.environ['OS_USERNAME']
  ]
  created = create_terraform_vars(order, public_ip, network_cidr, volume_size) + \
             create_ansible_vars(order)

  print('The following files have been created:')
  for conf in created:
    print('  {}'.format(conf))

  # context.run('git add {}'.format(' '.join(created)))

@invoke.task
def register(context, public_ip, owner=None):
  '''
  Registers an Hail cluster to local DNS

  :param context: PyInvoke context
  :param public_ip: the `public` network IP to associate to the cluster
  :param owner: the name of the user
  '''
  infoblox = {
    'host': 'infoblox-gm.internal.sanger.ac.uk',
    'username': os.environ['INFOBLOX_USERNAME'],
    'password': os.environ['INFOBLOX_PASSWORD']
  }
  zone = '{}.sanger.ac.uk'.format(os.environ['OS_PROJECT_NAME'])
  name = 'hail-{}'.format(owner or os.environ['OS_USERNAME'])
  connector = infoblox_client.connector.Connector(infoblox)
  record = infoblox_client.objects.ARecord.create(connector,
                                                  name='.'.join([name, zone]),
                                                  view='internal',
                                                  ip=public_ip,
                                                  update_if_exists=True)

@invoke.task
def create(context, owner=None, networking=False):
  '''
  Deploys an Hail cluster

  :param context: PyInvoke context
  :param networking: boolean flag to signal the need to create the networking
                     layer as well. Mainly needed for isolated, stand-alone
                     deployments.
  :param owner: the name of the user
  '''
  owner = owner or os.environ['OS_USERNAME']
  if networking:
    context.run('bash invoke.sh deployment create --name networking --owner {}'.format(owner))
  context.run('bash invoke.sh deployment create --name hail_volume --owner {}'.format(owner))
  env = {
    'TF_VAR_hail_volume': get_hail_volume_name(context, owner),
    "TF_VAR_openstack_flavours": get_openstack_flavours()
  }

  context.run('bash invoke.sh deployment create --name hail_cluster --owner {}'.format(owner), env=env)

@invoke.task
def destroy(context, owner=None, networking=False, yes_also_hail_volume=False):
  '''
  Decommission an Hail cluster

  :param context: PyInvoke context
  :param networking: boolean flag to signal the need to destroy the networking
                     layer as well. Mainly needed for isolated, stand-alone
                     deployments.
  :param owner: the name of the user
  :param yes_also_hail_volume: boolean flag to signal the decommission of the
                               persistent volume along with the cluster.
  '''
  owner = owner or os.environ['OS_USERNAME']
  volume = get_hail_volume_name(context, owner)
  env = {
    'TF_VAR_hail_volume': volume or "",
    "TF_VAR_password": "",
    "TF_VAR_openstack_flavours": "[]"
  }

  context.run('bash invoke.sh deployment destroy --name hail_cluster --owner {}'.format(owner), env=env)

  if networking:
    context.run('bash invoke.sh deployment destroy --name networking --owner {}'.format(owner))

  if yes_also_hail_volume and volume is not None:
    context.run('bash invoke.sh deployment destroy --name hail_volume --owner {}'.format(owner))

ns = invoke.Collection()
ns.add_task(init)
ns.add_task(register)
ns.add_task(create)
ns.add_task(destroy)
