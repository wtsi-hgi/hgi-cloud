# HDFS Guide

Create a cluster as described in the [setup guide](https://github.com/wtsi-hgi/hgi-cloud/blob/feature/hdfs/docs/setup.md), except make sure to checkout the HDFS branch: `git checkout feature/hdfs` after following the instructions under 'Prepare to Run the Provisioning Software'.

You can write to HDFS (Hadoop Distributed File System) by specifying the namenode and port that HDFS is connected to, along with the desired directory.
This is configured in `$HADOOP_HOME/etc/hadoop/core-site.xml`, and by default is set to `hdfs://spark-master:9820/`.

For example, to initialise Hail with HDFS storage, you can write something like this:
```python
tmp_dir = "hdfs://spark-master:9820/"
sc = pyspark.SparkContext()
hl.init(sc=sc, tmp_dir=tmp_dir, default_reference="GRCh38")
```


## Transferring data in and out of HDFS

There are multiple ways of moving data around in HDFS. To copy files from your cluster to HDFS you can use the
`hadoop fs -put` command, e.g. `hadoop fs -put ~/hail/tmp/scripts/ /scripts`.
Similarly you can copy data from HDFS with the `hadoop fs -get` command.

You can also transfer data easily between HDFS and S3 with the `hadoop distcp` command.
```
hadoop distcp hdfs:///<source_path> s3a://<bucket_name>/<target_path>
```

You can specify different access credentials with the -D flag, or change the configuration in `/opt/sanger.ac.uk/hgi/hadoop/etc/hadoop/core-site.xml`.
```
hadoop distcp \
-D fs.s3a.access.key=<access_key> \
-D fs.s3a.secret.key=<secret_key> \
hdfs:///<source_path> s3a://<bucket_name>/<target_path>
```

Find the official docs [here](https://hadoop.apache.org/docs/r2.7.1/).
