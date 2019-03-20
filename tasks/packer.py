import glob
import os
import os.path
import sys
import invoke
import openstack

def packer_network_name(context):
  env = context.config['env']
  os_release = context.config['os_release']
  template = 'uk-sanger-internal-openstack-{}-hgi-{}-network-main'
  return template.format(os_release, env)

def packer_var_file_option(context):
  env = context.config['env']
  os_release = context.config['os_release']
  return '-var-file=vars/{}-hgi-{}.json'.format(os_release, env)

def packer_var_options(network_name, source_image_name):
  cloud = openstack.connect(
    auth_url=os.environ['OS_AUTH_URL'],
    project_name=os.environ['OS_PROJECT_NAME'],
    username=os.environ['OS_USERNAME'],
    password=os.environ['OS_PASSWORD'],
    region_name=os.environ['OS_REGION_NAME'],
    app_name='invoke')

  options = '-var "network_id={}" -var "source_image_id={}"'

  return options.format(cloud.network.find_network(network_name).id,
                        cloud.compute.find_image(source_image_name).id)

@invoke.task()
def validate(context, source_image_name='bionic-server'):
  template = context.config['packer_template']
  var_file = packer_var_file_option(context)
  network_name = packer_network_name(context)
  with context.cd('packer'):
    options = '{} {}'.format(packer_var_file_option(context),
                             packer_var_options(network_name, source_image_name))
    context.run('packer validate {} {}'.format(options, template))

@invoke.task(validate, optional=['force', 'on_error', 'debug'])
def build(context, source_image_name='bionic-server', on_error='cleanup', force=False, debug=False):
  template = context.config['packer_template']
  var_file = packer_var_file_option(context)
  network_name = packer_network_name(context)
  options = '{} {} -on-error={}'.format(packer_var_file_option(context),
                                        packer_var_options(network_name, source_image_name),
                                        on_error)
  if force:
    options += ' -force'
  if debug:
    options += ' -debug'
  with context.cd('packer'):
    context.run('packer build {} {}'.format(options, template))
