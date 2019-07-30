'''
This group of tasks deals with high level operations on users.
'''
import invoke
import glob
import os
import os.path
import sys
import tempfile

def bucket_name(context):
  '''
  Returns the bucket name

  :param context: PyInvoke context
  '''
  return 's3://' + '-'.join([
    context.config['meta']['datacenter'],
    context.config['meta']['programme'],
    'bucket',
    os.environ['OS_USERNAME']
  ])

def keypair_name(context):
  '''
  Returns the keypair object name

  :param context: PyInvoke context
  '''
  return '-'.join([
    context.config['meta']['datacenter'],
    context.config['meta']['programme'],
    'keypair',
    os.environ['OS_USERNAME']
  ])

def run_s3cmd(context, s3cfg, command):
  '''
  Sets up options and runs `s3cmd`

  :param context: PyInvoke context
  :param s3cfg: path to `.s3cfg`
  :param command: the `s3cmd` arguments
  '''
  config = os.path.expanduser(s3cfg)
  options = '--config={}'.format(config) if os.path.exists(s3cfg) else ''
  s3cmd = 's3cmd {} {}'.format(options, command)
  context.run(s3cmd, warn=True)

@invoke.task
def create(context, public_key='~/.ssh/id_rsa.pub', s3cfg='~/.s3cfg'):
  '''
  Creates user's bucket and keypair object

  :param context: PyInvoke context
  :param public_key: path to SSH public key
  :param s3cfg: path to `.s3cfg`
  '''
  openstack = 'openstack keypair create --public-key={} {}'
  key_path = os.path.expanduser(public_key)
  context.run(openstack.format(key_path, keypair_name(context)), warn=True)
  bucket = bucket_name(context)
  run_s3cmd(context, s3cfg, 'mb {}'.format(bucket))

@invoke.task
def destroy(context, yes_also_the_bucket=False, s3cfg='~/.s3cfg'):
  '''
  Destroys user's bucket and keypair object

  :param context: PyInvoke context
  :param s3cfg: path to `.s3cfg`
  :param yes_also_the_bucket: also destroys the bucket with all its content
  '''
  openstack = 'openstack keypair delete {}'
  context.run(openstack.format(keypair_name(context)), warn=True)
  if yes_also_the_bucket:
    run_s3cmd(context, s3cfg, 'del --force --recursive {}'.format(bucket_name(context)))
    run_s3cmd(context, s3cfg, 'rb {}'.format(bucket_name(context)))

ns = invoke.Collection()
ns.add_task(create)
ns.add_task(destroy)
