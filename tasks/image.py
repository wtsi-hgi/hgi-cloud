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

import glanceclient

auth = keystoneauth1.identity.v3.Password(user_domain_name=os.environ['OS_USER_DOMAIN_NAME'],
                                          username=os.environ['OS_USERNAME'],
                                          password=os.environ['OS_PASSWORD'],
                                          project_domain_name=os.environ['OS_PROJECT_DOMAIN_ID'],
                                          project_name=os.environ['OS_PROJECT_NAME'],
                                          auth_url=os.environ['OS_AUTH_URL'])
session = keystoneauth1.session.Session(auth=auth)

keystone = keystoneclient.v3.client.Client(session=session)
glance = glanceclient.Client('2', session=session)

openstack = openstack_client.connect(auth_url=os.environ['OS_AUTH_URL'],
                                     project_name=os.environ['OS_PROJECT_NAME'],
                                     username=os.environ['OS_USERNAME'],
                                     password=os.environ['OS_PASSWORD'],
                                     region_name=os.environ['OS_REGION_NAME'],
                                     app_name='invoke')

now = datetime.datetime.utcnow().strftime('%Y%m%d%H%M%S')

def default_version(context):
  config_version = context.config['role']['version']
  return now if (config_version == '0.0.0') else config_version

def packer_options(context, role_name, role_version=None):
  network_template = '{}-{}-{}-network-main'
  network_name = network_template.format(context.config['meta']['datacenter'],
                                         context.config['meta']['programme'],
                                         context.config['meta']['env'])
  network_id = openstack.network.find_network(network_name).id
  var_file = 'vars/{}-{}.json'.format(context.config['meta']['datacenter'],
                                      context.config['meta']['programme'])
  return ' '.join([
    '-var "network_id={}"'.format(network_id),
    '-var "role_name={}"'.format(role_name),
    '-var "role_version={}"'.format(role_version or default_version(context)),
    '-var-file={}'.format(var_file)
  ])

def get_image(context, role_name, role_version):
  image_name = '-'.join([context.config['meta']['datacenter'],
                         context.config['meta']['programme'],
                         'image', role_name, role_version or default_version(context)])
  return openstack.image.find_image(image_name)


@invoke.task()
def validate(context):
  with context.cd('packer'):
    context.run('packer validate {} image.json'.format(packer_options(context, 'validate', '0.0.0')))

@invoke.task(validate, optional=['version', 'force', 'on_error', 'debug'])
def build(context, role_name, role_version=None, on_error='cleanup', force=False, debug=False):
  image = get_image(context, role_name, role_version)
  if not image:
    options = packer_options(context, role_name, role_version) + \
              ' -on-error={}'.format(on_error)
    if force:
      options += ' -force'
    if debug:
      options += ' -debug'
    with context.cd('packer'):
      context.run('packer build {} image.json'.format(options))
  else:
    print("Skipping {}: image is already available".format(image.name))

@invoke.task(pre=[build])
def promote(context, to, role_name, role_version):
  user = openstack.identity.get_user_id()
  image_id = get_image(context, role_name, role_version).id
  project = next((p for p in keystone.projects.list(user=user) if p.name == to))
  glance.image_members.create(image_id, project.id)
  glance.image_members.update(image_id, project.id, 'accepted')

@invoke.task()
def accept(context, image_name):
  image_id = openstack.image.find_image(image_name).id
  glance.image_members.update(image_id, os.environ['OS_PROJECT_ID'], 'accepted')

@invoke.task()
def share(context, with_, role_name, role_version):
  image_id = get_image(context, role_name, role_version).id
  glance.image_members.create(image_id, with_)

ns = invoke.Collection()
ns.add_task(validate)
ns.add_task(build, default=True)
ns.add_task(promote)
ns.add_task(share)
ns.add_task(accept)