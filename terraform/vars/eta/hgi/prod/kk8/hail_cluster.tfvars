spark_master_flavor_name      = "m2.medium"
spark_slaves_count            = 50
spark_slaves_flavor_name      = "m2.medium"
spark_master_external_address = "172.27.82.193"
#if you need hdfs volume and have used the feature/hdfs branch uncomment these lines:
spark_master_role_version     = "feature/hdfs"
spark_slaves_role_version     = "feature/hdfs"
spark_local_dir ="/opt/sanger.ac.uk/hgi/hail/tmp/"
  
