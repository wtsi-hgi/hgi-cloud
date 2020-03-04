spark_master_flavor_name      = "m1.large"
spark_slaves_count            = 50
spark_slaves_flavor_name      = "m1.large"
spark_master_flavor_name      = "m1.medium"
spark_slaves_count            = 100
spark_slaves_flavor_name      = "m1.medium"
spark_master_external_address = "172.27.83.152"
# if you need hdfs volume and have used the feature/hdfs branch uncomment these lines:
spark_master_role_version     = "feature/hdfs"
spark_slaves_role_version     = "feature/hdfs"
spark_local_dir ="/opt/sanger.ac.uk/hgi/hail/tmp/"
