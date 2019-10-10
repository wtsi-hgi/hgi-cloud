


# What tasks needs to be done?

# - invoke.sh calls tasks/docker.py with arguments: create | destroy, owner name, and whether to create with networking or not
# - 


import os
import invoke 


def create_terraform_vars(order, public_ip, network_cidr):
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

  tfvars = os.path.join(dirname, 'docker_swarm.tfvars')
  if not os.path.exists(tfvars):
    with open(tfvars, 'w') as conf:
      conf.write('docker_manager_external_address = "{}"\n'.format(public_ip))
    created.append(tfvars)
  else:
    print('Skipping {}: it already exists'.format(tfvars))

  tfvars = os.path.join(dirname, 'networking_swarm.tfvars')
  if network_cidr and not os.path.exist(tfvars):
    with open(tfvars, 'w') as conf:
      conf.write('main_subnet_cidr = "{}"\n'.format(network_cidr))
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

  for name in order + ['docker_swarm']:
    if not os.path.exists(dirname):
      os.mkdir(dirname)
    yml = os.path.join(dirname, '{}.yml'.format(name))
    if not os.path.exists(yml):
      with open(yml, 'w') as f:
        f.write("---\n# Automatically generated\n{}\n")
      created.append(yml)
    dirname = os.path.join(dirname, name)

  os.path.exists(dirname) or os.mkdir(dirname)
  for name in ('docker-swarm-manager', 'docker-swarm-worker'):
    yml = os.path.join(dirname, '{}.yml'.format(name))
    if not os.path.exists(yml):
      with open(yml, 'w') as f:
        f.write("---\n# Automatically generated\n{}\n")
      created.append(yml)

  return created

@invoke.task
def init(context, public_ip, network_cidr = None, owner = None):
	'''
	Initialises a Docker Swarm configuration

	'''

	order = [
		context.config['meta']['datacenter'],
		context.config['meta']['programme'],
		context.config['meta']['env'],
		owner or os.environ['OS_USERNAME']
	]

	created = create_terraform_vars(order, public_ip, network_cidr) + \
			  create_ansible_vars(order)

@invoke.task # decorator pattern
def create(context, owner = None, networking =False):
	'''
	Deploys a Docker Swarm cluster
	:param context: PyInvoke context
	:param owner: the name of the user
	:param networking: boolean flag to signal the need to create the networking layer as well. 
	'''
	owner = owner or os.environ['OS_USERNAME']
	if networking:
		context.run('bash invoke.sh deployment create --name networking_swarm --owner {}'.format(owner))
	context.run('bash invoke.sh deployment create --name docker_swarm --owner {}'.format(owner))



@invoke.task
def destroy(context, owner=None, networking=False):
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
  # volume = get_hail_volume_name(context, owner)
  env = {
    # 'TF_VAR_hail_volume': volume or "",
    "TF_VAR_password": ""
  }

  context.run('bash invoke.sh deployment destroy --name docker_swarm --owner {}'.format(owner), env=env)

  if networking:
    context.run('bash invoke.sh deployment destroy --name networking --owner {}'.format(owner))

  # if yes_also_hail_volume and volume is not None:
  #   context.run('bash invoke.sh deployment destroy --name hail_volume --owner {}'.format(owner))



ns = invoke.Collection()
ns.add_task(init)
# ns.add_task(register)
ns.add_task(create)
ns.add_task(destroy)





