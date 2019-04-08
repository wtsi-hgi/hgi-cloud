import glob
import os
import os.path
import sys
import invoke
import openstack

def packer_options(context):
  cloud = openstack.connect(auth_url=os.environ['OS_AUTH_URL'],
                            project_name=os.environ['OS_PROJECT_NAME'],
                            username=os.environ['OS_USERNAME'],
                            password=os.environ['OS_PASSWORD'],
                            region_name=os.environ['OS_REGION_NAME'],
                            app_name='invoke')
  network_template = 'uk-sanger-internal-openstack-{}-{}-{}-network-build'
  network_name = network_template.format(context.config['meta']['release'],
                                         context.config['meta']['programme'],
                                         context.config['meta']['env'])
  network_id = cloud.network.find_network(network_name).id

  options = '-var "network_id={}" -var "role_name={}" -var "role_version={}" -var-file=vars/{}-{}-{}.json'

  return options.format(network_id,
                        context.config['object']['name'],
                        context.config['object']['version'],
                        context.config['meta']['release'],
                        context.config['meta']['programme'],
                        context.config['meta']['env'])

@invoke.task()
def validate(context):
  with context.cd('packer'):
    context.run('packer validate {} image.json'.format(packer_options(context)))

@invoke.task(validate, optional=['force', 'on_error', 'debug'])
def build(context, on_error='cleanup', force=False, debug=False):
  options = '{} -on-error={}'.format(packer_options(context), on_error)
  if force:
    options += ' -force'
  if debug:
    options += ' -debug'
  with context.cd('packer'):
    context.run('packer build {} image.json'.format(options))
