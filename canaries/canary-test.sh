#!/bin/bash -e
declare -a _CLASSPATH=(
  "${HAIL_HOME}/build/libs/hail-all-spark.jar"
  "${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-core-1.10.6.jar"
  "${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-kms-1.10.6.jar"
  "${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-s3-1.10.6.jar"
  "${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-2.8.2.jar"
)
export HAIL_SESSION="$(mktemp --directory /tmp/hail.XXXXXXXXXX)"
echo created directory $HAIL_SESSION
JARS="$(IFS=, ; echo "${_CLASSPATH[*]}")"
/opt/sanger.ac.uk/hgi/anaconda3/bin/pyspark \
  --jars "${JARS}" \
  --conf "spark.driver.extraJavaOptions=-Dderby.system.home=${HAIL_SESSION}" \
  --conf "spark.driver.extraClassPath=${HAIL_HOME}/build/libs/hail-all-spark.jar" \
  --conf "spark.executor.extraClassPath=${HAIL_HOME}/build/libs/hail-all-spark.jar" \
  --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
  --conf spark.kryo.registrator=is.hail.kryo.HailKryoRegistrator <<CANARY
import os
import hail
import pyspark.context
 
app_name = 'canary'
 
# The interactive session creates a global SparkContext, we have to create it
sc = pyspark.context.SparkContext(appName=app_name, sparkHome=os.environ['SPARK_HOME'])
log = os.path.join(os.environ['HAIL_SESSION'], '{}.log'.format(app_name))
hail.init(sc=sc, app_name=app_name, log=log, append=True)
 
mt = hail.balding_nichols_model(n_populations=3, n_samples=50, n_variants=100)
print(mt.count())
 
hadoop_config = sc._jsc.hadoopConfiguration()
hadoop_config.set('fs.s3a.access.key', '...')
hadoop_config.set('fs.s3a.secret.key', '...')
mt = hail.import_vcf('s3a://1kg/1kg.vcf.bgz', force_bgz=True)
print(mt.describe())
print(mt.count())
CANARY
 
[ "$?" == 0 ] && rm --recursive --force --verbose "${HAIL_SESSION}"
