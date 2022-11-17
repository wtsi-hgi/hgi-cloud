'''
This group of tasks deals with building and storing customised spark
distributions.
'''
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
import invoke

@invoke.task
def clean(context):
  '''
  Cleans the build directory

  :param context: PyInvoke context
  '''
  build_prefix = context.config['build_prefix']
  for path in glob.glob(os.path.join(build_prefix, 'spark-*/')):
    if os.path.exists(path):
      shutil.rmtree(path)
  if not os.path.isdir(build_prefix):
    os.makedirs(build_prefix)

@invoke.task
def download(context, spark_version=None):
  '''
  Downloads the source distribution

  :param context: PyInvoke context
  :param spark_version: the version to download
  '''
  build_prefix = context.config['build_prefix']
  version = spark_version or context.config['spark_distribution']['version']
  basename = 'spark-{}.tgz'.format(version)
  filename = os.path.join(build_prefix, basename)
  if not os.path.isfile(filename):
    mirror = context.config['spark_distribution']['mirror']
    url = '{}/spark-{}/{}'.format(mirror, version, basename)
    print('Downloading source: {}'.format(url))
    urllib.request.urlretrieve (url, filename)
  print('File downloaded: {}'.format(filename))

@invoke.task(pre=[download])
def sha512(context, spark_version=None):
  '''
  Check the downloaded spark source against the configured sha512 checksum

  :param context: PyInvoke context
  :param spark_version: the downloaded version
  '''
  build_prefix = context.config['build_prefix']
  version = spark_version or context.config['spark_distribution']['version']
  basename = 'spark-{}.tgz'.format(version)
  configured = ''.join(context.config['spark_distribution']['sha512'][version].split()).lower()
  with open(os.path.join(build_prefix, basename), 'rb') as tgz:
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
  '''
  Extracts the downloaded spark source

  :param context: PyInvoke context
  :param spark_version: the downloaded version
  '''
  build_prefix = context.config['build_prefix']
  version = spark_version or context.config['spark_distribution']['version']
  basename = 'spark-{}.tgz'.format(version)
  source = '{}/spark-{}'.format(build_prefix, version)
  if not os.path.isdir(source):
    with tarfile.open(os.path.join(build_prefix, basename), 'r:gz') as tgz:
      print('Extracting source: {}'.format(source))
      def is_within_directory(directory, target):
          
          abs_directory = os.path.abspath(directory)
          abs_target = os.path.abspath(target)
      
          prefix = os.path.commonprefix([abs_directory, abs_target])
          
          return prefix == abs_directory
      
      def safe_extract(tar, path=".", members=None, *, numeric_owner=False):
      
          for member in tar.getmembers():
              member_path = os.path.join(path, member.name)
              if not is_within_directory(path, member_path):
                  raise Exception("Attempted Path Traversal in Tar File")
      
          tar.extractall(path, members, numeric_owner=numeric_owner) 
          
      
      safe_extract(tgz, build_prefix)
  print('Source extracted: {}'.format(source))

@invoke.task(pre=[extract])
def build(context, spark_version=None):
  '''
  Builds the downloaded spark source

  :param context: PyInvoke context
  :param spark_version: the downloaded version
  '''
  version = spark_version or context.config['spark_distribution']['version']
  build_prefix = context.config['build_prefix']
  build_directory = os.path.join(build_prefix, 'spark-{}'.format(version))
  distribution = os.path.join(build_directory, context.config['spark_distribution']['basename'])
  if not os.path.isfile(distribution):
    with context.cd(build_directory):
      build_command = """R_HOME=/usr/lib/R \
JAVA_HOME=/usr/lib/jvm/java-{}-openjdk-amd64 \
MAVEN_OPTS="-Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn" \
./dev/make-distribution.sh \
  --name {} \
  --tgz \
  --pip \
  --r \
  --batch-mode \
  -DskipTests \
  -Dhadoop.version={} \
  -Pyarn \
  -Phadoop-{} \
  -Pnetlib-lgpl \
  -Psparkr \
  -Phive \
  -Pkubernetes \
  -Phive-thriftserver \
  -Pmesos""".format(context.config['spark_distribution']['jdk_version'],
                    context.config['spark_distribution']['name'],
                    context.config['spark_distribution']['hadoop_version'],
                    context.config['spark_distribution']['hadoop_profile'])
      context.run(build_command)
  print('Distribution built: {}'.format(distribution))

@invoke.task(pre=[build])
def upload(context):
  '''
  Uploads the binary distribution to the user's bucket

  :param context: PyInvoke context
  '''
  basename = context.config['spark_distribution']['basename']
  version = context.config['spark_distribution']['version']
  build_prefix = context.config['build_prefix']
  upload_prefix = context.config['upload_prefix']
  bucket_name = context.config['spark_distribution']['bucket_name']

  distribution = os.path.join(build_prefix, 'spark-{}'.format(version), basename)
  with open(distribution, 'br') as spark_tgz:
    body = spark_tgz.read()

  s3 = boto3.resource('s3', endpoint_url='https://{}'.format(os.environ['AWS_S3_ENDPOINT']))
  object_path = os.path.join(upload_prefix, 'spark-{}'.format(version), basename)
  object_name = 's3://{}/{}'.format(bucket_name, object_path)
  print('Uploading distribution: {}'.format(object_name))
  s3.Object(bucket_name, object_path).put(ACL='public-read', Body=body)

@invoke.task(post=[upload])
def create(context, version='2.4.3', user=None, jdk_version=8, hadoop_version='2.7.1', hadoop_profile=None, force=False):
  '''
  The entry point task to create a Spark binary distribution

  :param context: PyInvoke context
  :param version: Spark version to use
  :param user: owner of the bucket to upload the binary distribution to
  :param jdk_version: JDK version to use
  :param hadoop_version: Hadoop version to use
  :param hadoop_profile: Hadoop profile to use
  :param force: forces the process
  '''
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

  upload_prefix = context.config['upload_prefix']
  object_path = os.path.join(upload_prefix, 'spark-{}'.format(version), basename)
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

ns = invoke.Collection()
ns.add_task(clean)
ns.add_task(create)
