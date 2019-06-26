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

__config = {}

def bucket_name(context, user):
  return '-'.join([
    context.config['meta']['datacenter'],
    context.config['meta']['programme'],
    'bucket',
    user or os.environ['OS_USERNAME']
  ])

@invoke.task
def cleanup(context):
  build_dirname = context.config['spark']['build_dirname']
  for path in [build_dirname]:
    if os.path.isdir(path):
      shutil.rmtree(path)
    if not os.path.isdir(path):
      os.makedirs(path)

@invoke.task(pre=[cleanup])
def download(context, spark_version=None):
  build_dirname = context.config['spark']['build_dirname']
  version = spark_version or context.config['spark']['version']
  basename = 'spark-{}.tgz'.format(version)
  filename = os.path.join(build_dirname, basename)
  mirror = context.config['spark']['mirror']
  url = '{}/spark-{}/{}'.format(mirror, version, basename)
  print('Downloading source: {}'.format(url))
  urllib.request.urlretrieve (url, filename)

@invoke.task(pre=[download])
def sha512(context, spark_version=None):
  build_dirname = context.config['spark']['build_dirname']
  version = spark_version or context.config['spark']['version']
  basename = 'spark-{}.tgz'.format(version)
  with open(os.path.join(build_dirname, basename), 'rb') as tgz:
    digest = hashlib.sha512(tgz.read()).hexdigest()
    print('Verifying checksum(sha512):')
    for line in context.config['spark']['sha512'][version].splitlines():
      print('  {}'.format(line))
    if hmac.compare_digest(digest, context.config['spark']['sha512'][version]):
      print('Checksum failed!\n{}'.format(digest))
      sys.exit(1)

@invoke.task(pre=[sha512])
def extract(context, spark_version=None):
  build_dirname = context.config['spark']['build_dirname']
  version = spark_version or context.config['spark']['version']
  basename = 'spark-{}.tgz'.format(version)
  with tarfile.open(os.path.join(build_dirname, basename), 'r:gz') as tgz:
    print('Extracting source: {}/spark-{}'.format(build_dirname, version))
    tgz.extractall(build_dirname)

@invoke.task(pre=[extract])
def build(context, spark_version=None):
  build_dirname = context.config['spark']['build_dirname']
  version = spark_version or context.config['spark']['version']
  build_directory = os.path.join(build_dirname, 'spark-{}'.format(version))
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
      -P{} \
      -Phive \
      -Phive-thriftserver \
      -Pmesos""".format(context.config['spark']['jdk_version'],
                        context.config['spark']['name'],
                        context.config['spark']['hadoop_version'],
                        context.config['spark']['hadoop_profile'])
    context.run(build_command)
  # context.config['spark']['basename']


@invoke.task(pre=[build])
def upload(context):
  filename = os.path.join(context.config['spark']['upload_dirname'],
                          context.config['spark']['basename'])

  s3 = boto3.resource('s3')

@invoke.task(post=[build])
def create(context, version='2.4.3', user=None, jdk_version=8, hadoop_version='2.7.7', hadoop_profile=None):
  default_profile = 'hadoop-{}'.format('.'.join(hadoop_version.split('.')[:2]))
  context.config['spark']['version'] = version
  context.config['spark']['jdk_version'] = jdk_version
  context.config['spark']['hadoop_version'] = hadoop_version
  context.config['spark']['hadoop_profile'] = hadoop_profile or default_profile
  context.config['spark']['name'] = 'hgi-hadoop{}'.format(hadoop_profile or default_profile)
  context.config['spark']['basename'] = 'spark-{}-bin-hgi-{}.tgz'.format(version, hadoop_version)
  filename = os.path.join(context.config['spark']['upload_dirname'],
                          'spark-{}'.format(version),
                          context.config['spark']['basename'])

  # s3 = boto3.resource('s3')
  # try:
  #     s3.Object(bucket_name(context, user), filename).get()
  # except botocore.exceptions.ClientError as e:
  #     if e.response['Error']['Code'] != "404":
  #       raise 
  # else:
  #   if force:
  #     print('Forcing the building process')
  #   else:
  #     print('Distribution already exists, skipping.')
  #     sys.exit(0)
