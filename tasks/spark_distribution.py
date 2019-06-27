import glob
import hashlib
import hmac
import io
import os
import os.path
import shutil
import sys
import tarfile
import urllib.request

import boto3
import botocore
import gnupg
import invoke

@invoke.task
def clean(context):
  build_dirname = context.config['spark_distribution']['build_dirname']
  for path in [build_dirname]:
    if os.path.isdir(path):
      shutil.rmtree(path)
    if not os.path.isdir(path):
      os.makedirs(path)

@invoke.task
def download(context, spark_version=None):
  build_dirname = context.config['spark_distribution']['build_dirname']
  version = spark_version or context.config['spark_distribution']['version']
  basename = 'spark-{}.tgz'.format(version)
  filename = os.path.join(build_dirname, basename)
  if not os.path.isfile(filename):
    mirror = context.config['spark_distribution']['mirror']
    url = '{}/spark-{}/{}'.format(mirror, version, basename)
    print('Downloading source: {}'.format(url))
    urllib.request.urlretrieve (url, filename)
  print('File downloaded: {}'.format(filename))

@invoke.task(pre=[download])
def sha512(context, spark_version=None):
  build_dirname = context.config['spark_distribution']['build_dirname']
  version = spark_version or context.config['spark_distribution']['version']
  basename = 'spark-{}.tgz'.format(version)
  configured = ''.join(context.config['spark_distribution']['sha512'][version].split()).lower()
  with open(os.path.join(build_dirname, basename), 'rb') as tgz:
    calculated = hashlib.sha512(tgz.read()).hexdigest()
    if not hmac.compare_digest(calculated, configured):
      print('Checksum failed!')
      print('  Calculated: {}'.format(calculated))
      print('  Configured: {}'.format(configured))
      sys.exit(1)
    else:
      print('Checksum verified: {}'.format(calculated))

@invoke.task(pre=[sha512])
def extract(context, spark_version=None):
  build_dirname = context.config['spark_distribution']['build_dirname']
  version = spark_version or context.config['spark_distribution']['version']
  basename = 'spark-{}.tgz'.format(version)
  source = '{}/spark-{}'.format(build_dirname, version)
  if not os.path.isdir(source):
    with tarfile.open(os.path.join(build_dirname, basename), 'r:gz') as tgz:
      print('Extracting source: {}'.format(source))
      tgz.extractall(build_dirname)
  print('Source extracted: {}'.format(source))

@invoke.task(pre=[extract])
def build(context, spark_version=None):
  version = spark_version or context.config['spark_distribution']['version']
  build_dirname = context.config['spark_distribution']['build_dirname']
  build_directory = os.path.join(build_dirname, 'spark-{}'.format(version))
  distribution = os.path.join(build_directory, context.config['spark_distribution']['basename'])
  if not os.path.isfile(distribution):
    with context.cd(build_directory):
      build_command = """R_HOME=/usr/lib/R \
JAVA_HOME=/usr/lib/jvm/java-{}-openjdk-amd64 \
MAVEN_OPTS="-Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn" \
./dev/make-distribution.sh \
  --name {} \
  --tgz \
  -B \
  -Dhadoop.version={} \
  -Pnetlib-lgpl \
  -Psparkr \
  -Pyarn \
  -Phadoop-{} \
  -Phive \
  -Phive-thriftserver \
  -Pmesos""".format(context.config['spark_distribution']['jdk_version'],
                    context.config['spark_distribution']['name'],
                    context.config['spark_distribution']['hadoop_version'],
                    context.config['spark_distribution']['hadoop_profile'])
      context.run(build_command)
  print('Distribution built: {}'.format(distribution))

@invoke.task(pre=[build])
def upload(context):
  basename = context.config['spark_distribution']['basename']
  version = context.config['spark_distribution']['version']
  build_dirname = context.config['spark_distribution']['build_dirname']
  upload_dirname = context.config['spark_distribution']['upload_dirname']
  bucket_name = context.config['spark_distribution']['bucket_name']

  distribution = os.path.join(build_dirname, 'spark-{}'.format(version), basename)
  with open(distribution, 'br') as spark_tgz:
    body = spark_tgz.read()

  s3 = boto3.resource('s3', endpoint_url='https://{}'.format(os.environ['AWS_S3_ENDPOINT']))
  object_path = os.path.join(upload_dirname, 'spark-{}'.format(version), basename)
  object_name = 's3://{}/{}'.format(bucket_name, object_path)
  print('Uploading distribution: {}'.format(object_name))
  s3.Object(bucket_name, object_path).put(ACL='public-read', Body=body)

@invoke.task(post=[upload])
def create(context, version='2.4.3', user=None, jdk_version=8, hadoop_version='2.7.7', hadoop_profile=None, force=False):
  default_profile = '.'.join(hadoop_version.split('.')[:2])
  name = 'netlib-hadoop{}'.format(hadoop_profile or default_profile)
  basename = 'spark-{}-bin-{}.tgz'.format(version, name)
  bucket_name = '-'.join([
    context.config['meta']['datacenter'],
    context.config['meta']['programme'],
    'bucket',
    user or os.environ['OS_USERNAME']])

  context.config['spark_distribution']['bucket_name'] = bucket_name
  context.config['spark_distribution']['version'] = version
  context.config['spark_distribution']['jdk_version'] = jdk_version
  context.config['spark_distribution']['hadoop_version'] = hadoop_version
  context.config['spark_distribution']['hadoop_profile'] = hadoop_profile or default_profile
  context.config['spark_distribution']['name'] = name
  context.config['spark_distribution']['basename'] = basename

  upload_dirname = context.config['spark_distribution']['upload_dirname']
  object_path = os.path.join(upload_dirname, 'spark-{}'.format(version), basename)
  object_name = 's3://{}/{}'.format(bucket_name, object_path)
  s3 = boto3.resource('s3', endpoint_url='https://{}'.format(os.environ['AWS_S3_ENDPOINT']))
  try:
    s3.Object(bucket_name, object_path).load()
  except botocore.exceptions.ClientError as e:
    if e.response['Error']['Code'] == "404":
      print('Distribution does not exists: {}'.format(object_name))
    else:
      raise
  else:
    if force:
      print('Forcing the building process...')
    else:
      print('Distribution already exists: {}'.format(object_name))
      sys.exit(0)
