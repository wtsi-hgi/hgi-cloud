import invoke
import glob
import os
import os.path
import sys

def run_s3cmd(context, s3cfg, command, *args):
  config = os.path.expanduser(s3cfg)
  options = '--config={}'.format(config) if os.path.exists(s3cfg) else ''
  bucket = '-'.join([
    context.config['meta']['datacenter'],
    context.config['meta']['programme'],
    'bucket',
    context.config['deployment']['owner']
  ])
  s3cmd = 's3cmd {} {} s3://{} {}'
  context.run(s3cmd.format(options, command, bucket, ' '.join(args)), warn=True)

def keypair_name(context):
  return '-'.join([
    context.config['meta']['datacenter'],
    context.config['meta']['programme'],
    'keypair',
    context.config['deployment']['owner']
  ])

@invoke.task
def create(context, s3cfg='~/.s3cfg', public_key='~/.ssh/id_rsa.pub'):
  openstack = 'openstack keypair create --public-key={} {}'
  key_path = os.path.expanduser(public_key)
  context.run(openstack.format(key_path, keypair_name(context)), warn=True)
  run_s3cmd(context, s3cfg, 'mb')

@invoke.task
def delete(context, s3cfg='~/.s3cfg', yes_also_the_bucket=False):
  openstack = 'openstack keypair delete {}'
  context.run(openstack.format(keypair_name(context)), warn=True)
  if yes_also_the_bucket:
    run_s3cmd(context, s3cfg, 'rb')

