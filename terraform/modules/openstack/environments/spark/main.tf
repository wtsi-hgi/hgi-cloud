provider "openstack" {
  version = "~> 1.16"
}
provider "template" {
  version = "~> 2.1"
}

locals {
  deployment_version = "0.0.0"
  dependency = {}
}

data "openstack_networking_network_v2" "spark_network" {
  name = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-network-main"
}

module "spark_cluster" {
  source                    = "../../deployments/spark_cluster"
  os_release                = "${var.os_release}"
  programme                 = "${var.programme}"
  env                       = "${var.env}"
  key_pair                  = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-keypair-mercury"
  deployment_name           = "primary"
  spark_masters_count       = 1
  spark_slaves_count        = 1
  spark_masters_flavor_name = "o2.large"
  spark_slaves_flavor_name  = "o2.large"
  spark_masters_affinity    = "soft-anti-affinity"
  spark_slaves_affinity     = "soft-anti-affinity"
  spark_masters_network     = "${data.openstack_networking_network_v2.spark_network.name}"
  spark_slaves_network      = "${data.openstack_networking_network_v2.spark_network.name}"
}

module "pet_cluster" {
  source                    = "../../deployments/pet_1"
  os_release                = "${var.os_release}"
  programme                 = "${var.programme}"
  env                       = "${var.env}"
  key_pair                  = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-keypair-mercury"
  deployment_name           = "primary"
  pet_subnet_cidr           = "${var.pet_subnet_cidr}"
  pet_masters_count         = 1
  pet_master_address        = "${var.pet_master_address}"
  pet_slaves_count          = 1
  pet_masters_flavor_name   = "o2.large"
  pet_slaves_flavor_name    = "o2.large"
  pet_masters_affinity      = "soft-anti-affinity"
  pet_slaves_affinity       = "soft-anti-affinity"
  dns_nameservers           = "${var.dns_nameservers}"
  external_network_name     = "${var.external_network_name}"
}

# module "spark_cluster2" {
#   source                    = "../../deployments/spark_cluster"
#   os_release                = "${var.os_release}"
#   programme                 = "${var.programme}"
#   env                       = "${var.env}"
#   key_pair                  = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-keypair-mercury"
#   deployment_name           = "secondary"
#   spark_masters_count       = 1
#   spark_slaves_count        = 3
#   spark_masters_flavor_name = "o2.small"
#   spark_slaves_flavor_name  = "o2.small"
#   spark_masters_affinity    = "soft-anti-affinity"
#   spark_slaves_affinity     = "soft-anti-affinity"
#   spark_masters_networks    = [ { name = "${module.spark_network.network_name}" } ]
#   spark_slaves_networks     = [ { name = "${module.spark_network.network_name}" } ]
# }

# module "spark_cluster3" {
#   source                    = "../../deployments/spark_cluster"
#   os_release                = "${var.os_release}"
#   programme                 = "${var.programme}"
#   env                       = "${var.env}"
#   key_pair                  = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-keypair-mercury"
#   deployment_name           = "tertiary"
#   spark_masters_count       = 1
#   spark_slaves_count        = 3
#   spark_masters_flavor_name = "o2.small"
#   spark_slaves_flavor_name  = "o2.small"
#   spark_masters_affinity    = "soft-anti-affinity"
#   spark_slaves_affinity     = "soft-anti-affinity"
#   spark_masters_networks    = [ { name = "${module.spark_network.network_name}" } ]
#   spark_slaves_networks     = [ { name = "${module.spark_network.network_name}" } ]
# }

# module "workstations" {
#   source          = "../../deployments/ssh_gateway"
#   os_release      = "${var.os_release}"
#   programme       = "${var.programme}"
#   env             = "${var.env}"
#   count           = 1
#   key_pair        = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-keypair-mercury"
#   deployment_name = "primary"
#   flavor_name     = "o2.small"
#   affinity        = "soft-anti-affinity"
#   networks        = [ { name = "${module.workstations_network.network_name}" } ]
# }

# module "consul" {
#   source          = "../../deployments/consul"
#   os_release      = "${var.os_release}"
#   programme       = "${var.programme}"
#   env             = "${var.env}"
#   count           = "${var.count}"
#   image_name      = "${var.image_name}"
#   flavor_name     = "${var.flavor_name}"
#   affinity        = "${var.affinity}"
#   subnet_cidr     = "${var.consensus_subnet_cidr}"
#   dns_nameservers = "${var.dns_nameservers}"
#   networks        = [ { name = "${module.management_network.network_name}" } ]
#   key_pair        = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-keypair-mercury"
#   security_groups = [
#     "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ping",
#     "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ssh",
#     "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-tcp-local",
#     "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-udp-local"
#   ]
# }
