import datetime
import glob
import os
import os.path
import sys
import invoke
import openstack as openstack_client

import keystoneauth1.identity.v3
import keystoneauth1.session
import keystoneclient.v3

auth = keystoneauth1.identity.v3.Password(user_domain_name=os.environ['OS_USER_DOMAIN_NAME'],
                                          username=os.environ['OS_USERNAME'],
                                          password=os.environ['OS_PASSWORD'],
                                          project_domain_name=os.environ['OS_PROJECT_DOMAIN_ID'],
                                          project_name=os.environ['OS_PROJECT_NAME'],
                                          auth_url=os.environ['OS_AUTH_URL'])
session = keystoneauth1.session.Session(auth=auth)
keystone = keystoneclient.v3.client.Client(session=session)

openstack = openstack_client.connect(auth_url=os.environ['OS_AUTH_URL'],
                                     project_name=os.environ['OS_PROJECT_NAME'],
                                     username=os.environ['OS_USERNAME'],
                                     password=os.environ['OS_PASSWORD'],
                                     region_name=os.environ['OS_REGION_NAME'],
                                     app_name='invoke')

now = datetime.datetime.utcnow().strftime('%Y%m%d%H%M%S')

def role_version(context):
  config_version = context.config['role']['version']
  return now if (config_version == '0.0.0') else config_version

def packer_options(context):
  network_template = '{}-{}-{}-network-main'
  network_name = network_template.format(context.config['meta']['datacenter'],
                                         context.config['meta']['programme'],
                                         context.config['meta']['env'])
  network_id = openstack.network.find_network(network_name).id
  var_file = 'vars/{}-{}-{}.json'.format(context.config['meta']['datacenter'],
                                         context.config['meta']['programme'],
                                         context.config['meta']['env'])
  return ' '.join([
    '-var "network_id={}"'.format(network_id),
    '-var "role_name={}"'.format(context.config['role']['name']),
    '-var "role_version={}"'.format(role_version(context)),
    '-var-file={}'.format(var_file)
  ])

def get_image(context):
  image_name = '-'.join([context.config['meta']['datacenter'],
                         context.config['meta']['programme'],
                         'image',
                         context.config['role']['name'],
                         role_version(context)])
  return openstack.image.find_image(image_name)


@invoke.task()
def validate(context):
  with context.cd('packer'):
    context.run('packer validate {} image.json'.format(packer_options(context)))

@invoke.task(validate, optional=['force', 'on_error', 'debug'])
def build(context, on_error='cleanup', force=False, debug=False):
  image = get_image(context)
  if not image:
    options = '{} -on-error={}'.format(packer_options(context), on_error)
    if force:
      options += ' -force'
    if debug:
      options += ' -debug'
    with context.cd('packer'):
      context.run('packer build {} image.json'.format(options))
  else:
    print("Skipping {}: image is already available".format(image.name))

@invoke.task(build)
def publish(context):
  # user_id = openstack.identity.get_user_id()
  image_id = get_image(context).id
  for project_id in context.config['image']['publish'].values():
    context.run('openstack image add project {} {}'.format(image_id, project_id))

@invoke.task()
def accept(context):
  image_id = get_image(context).id
  context.run('openstack image set --accept {}'.format(image_id))

ns = invoke.Collection()
ns.add_task(validate)
ns.add_task(build)
ns.add_task(publish, default=True)
ns.add_task(accept)
