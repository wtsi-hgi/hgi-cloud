import datetime
import glob
import os
import os.path
import shutil
import sys
import tarfile
import urllib.request

import boto3
import botocore
import invoke

def get_bucket_name(context):
  return '-'.join([
    context.config['meta']['datacenter'],
    context.config['meta']['programme'],
    'bucket',
    context.config['deployment']['owner']])

def get_container_name(context):
  return '-'.join([context.config['meta']['datacenter'],
                   context.config['meta']['programme'],
                   'docker',
                   context.config['role']['name'],
                   context.config['role']['version']])

@invoke.task
def clean(context):
  build_prefix = context.config['build_prefix']
  for path in glob.glob(os.path.join(build_prefix, 'containers', 'docker', '*')):
    if os.path.exists(path):
      os.remove(path)
      print('Removed {}'.format(path))
  if not os.path.isdir(build_prefix):
    os.makedirs(build_prefix)

  context.run('docker system prune --all --force')
  
@invoke.task
def validate(context):
  context.run('packer validate packer/docker.json')

@invoke.task(pre=[validate])
def save(context, role_name=None, role_version=None, on_error=None, force=None, debug=None):
  build_prefix = context.config['build_prefix']
  if role_name is not None:
    context.config['role']['name'] = role_name
  if role_version is not None:
    context.config['role']['version'] = role_version
  if on_error is not None:
    context.config['packer']['on_error'] = on_error
  if force is not None:
    context.config['packer']['force'] = force
  if debug is not None:
    context.config['packer']['debug'] = debug

  save_path = os.path.join(build_prefix, 'containers', 'docker')
  if not os.path.isdir(save_path):
    os.makedirs(save_path)

  container_name = get_container_name(context)
  saved_container = os.path.join(save_path, '{}.tar'.format(container_name))

  if not os.path.isfile(saved_container):
    var_file = 'packer/vars/{}-{}.json'.format(context.config['meta']['datacenter'],
                                        context.config['meta']['programme'])
    options = ' '.join([
      '-on-error={}'.format(context.config['packer']['on_error']),
      '-debug={}'.format(context.config['packer']['debug']),
      '-force={}'.format(context.config['packer']['force']),
      '-var "build_prefix={}"'.format(context.config['build_prefix']),
      '-var "role_name={}"'.format(context.config['role']['name']),
      '-var "role_version={}"'.format(context.config['role']['version']),
      '-var-file={}'.format(var_file)
    ])
    context.run('packer build {} packer/docker.json'.format(options))
    context.run('docker save hgi/{}:{} --output {}'.format(
                context.config['role']['name'],
                context.config['role']['version'],
                saved_container))
  else:
    print("Skipping {}: container is already build".format(saved_container))

@invoke.task(pre=[save])
def upload(context):
  upload_prefix = context.config['upload_prefix']
  build_prefix = context.config['build_prefix']

  bucket_name = get_bucket_name(context)
  container_name = get_container_name(context)
  # I could not make the checksum work
  for ext in ['tar']:
    container_file = os.path.join('containers', 'docker', '{}.{}'.format(container_name, ext))

    with open(os.path.join(build_prefix, container_file), 'br') as content:
      body = content.read()

    object_path = os.path.join(upload_prefix, container_file)
    object_name = 's3://{}/{}'.format(get_bucket_name(context), object_path)
    s3 = boto3.resource('s3', endpoint_url='https://{}'.format(os.environ['AWS_S3_ENDPOINT']))
    print('Uploading distribution: {}'.format(object_name))
    s3.Object(bucket_name, object_path).put(ACL='public-read', Body=body)

@invoke.task(post=[upload])
def create(context, role_name, role_version, user=None, on_error='cleanup', force=False, debug=False):
  context.config['role']['name'] = role_name
  context.config['role']['version'] = role_version
  context.config['packer']['on_error'] = on_error
  context.config['packer']['force'] = force
  context.config['packer']['debug'] = debug
  context.config['deployment']['owner'] = user or os.environ['OS_USERNAME']

  bucket_name = get_bucket_name(context)
  container_name = get_container_name(context)
  container_tar = os.path.join('containers', 'docker', '{}.tar'.format(container_name))

  upload_prefix = context.config['upload_prefix']
  build_prefix = context.config['build_prefix']

  object_path = os.path.join(upload_prefix, container_tar)
  object_name = 's3://{}/{}'.format(bucket_name, object_path)
  s3 = boto3.resource('s3', endpoint_url='https://{}'.format(os.environ['AWS_S3_ENDPOINT']))
  try:
    s3.Object(bucket_name, object_path).load()
  except botocore.exceptions.ClientError as e:
    if e.response['Error']['Code'] == "404":
      print('Docker container does not exist: {}'.format(object_name))
    else:
      raise
  else:
    if force:
      print('Forcing the building process...')
    else:
      print('Docker container already exists: {}'.format(object_name))
      sys.exit(0)

ns = invoke.Collection()
ns.add_task(clean)
ns.add_task(validate)
ns.add_task(save)
ns.add_task(create)
