import invoke
import glob
import os
import os.path
import sys

def packer_vars(context):
  env = context.config['env']
  os_release = context.config['os_release']
  return 'vars/{}-hgi-{}.json'.format(os_release, env)

@invoke.task()
def validate(context):
  var_file = packer_vars(context)
  template = context.config['packer_template']
  with context.cd('packer'):
    context.run('packer validate -var-file={} {}'.format(var_file, template))

@invoke.task(validate, optional=['force', 'on_error', 'debug'])
def build(context, force=False, on_error='cleanup', debug=False):
  var_file = packer_vars(context)
  template = context.config['packer_template']
  options = '-on-error={}'.format(on_error)
  if force:
    options += ' -force'
  if debug:
    options += ' -debug'
  packer_build = 'packer build {} -var-file={} {}'
  with context.cd('packer'):
    context.run(packer_build.format(options, var_file, template))
