# Networks that offer and internal service
workstations_subnet_cidr  = "192.168.224.0/27"
build_subnet_cidr         = "192.168.224.64/27"
management_subnet_cidr    = "192.168.224.128/27"
local_dns_nameservers     = ["192.168.224.158", "192.168.224.157", "192.168.224.156"]

# Accessories/Clustering/Consensus/Quorum networks
consensus_subnet_cidr     = "192.168.225.0/27"

main_subnet_cidr          = "192.168.226.0/23"

deployment_owner          = "mercury"
spark_slaves_image_name   = "eta-hgi-image-hail-base-0.0.8"
spark_masters_image_name  = "eta-hgi-image-hail-base-0.0.8"
