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

module "spark_network" {
  source                = "../../infrastructure/networks/routed"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  external_network_name = "${var.external_network_name}"
  network_name          = "main"
  subnet_cidr           = "${var.spark_subnet_cidr}"
  dns_nameservers       = "${var.dns_nameservers}"
}

module "workstations_network" {
  source                = "../../infrastructure/networks/extra/network/"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  subnet_cidr           = "${var.workstations_subnet_cidr}"
  network_name          = "workstations"
  router_id             = "${module.spark_network.router_id}"
  dns_nameservers       = "${var.dns_nameservers}"
}

module "management_network" {
  source                = "../../infrastructure/networks/extra/network/"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  subnet_cidr           = "${var.management_subnet_cidr}"
  network_name          = "management"
  router_id             = "${module.spark_network.router_id}"
  dns_nameservers       = "${var.dns_nameservers}"
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
  spark_masters_network     = "${module.spark_network.network_name}"
  spark_slaves_network      = "${module.spark_network.network_name}"
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
