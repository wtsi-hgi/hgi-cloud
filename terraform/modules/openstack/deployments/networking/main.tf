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

module "main_network" {
  source                = "../../infrastructure/networks/routed"
  datacenter            = "${var.datacenter}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  deployment_owner      = "${var.deployment_owner}"
  external_network_name = "${var.external_network_name}"
  network_name          = "main"
  subnet_cidr           = "${var.main_subnet_cidr}"
  dns_nameservers       = "${var.external_dns_nameservers}"
}

module "management_network" {
  source                = "../../infrastructure/networks/extra/network/"
  datacenter            = "${var.datacenter}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  deployment_owner      = "${var.deployment_owner}"
  subnet_cidr           = "${var.management_subnet_cidr}"
  network_name          = "management"
  router_id             = "${module.main_network.router_id}"
  subnet_pool_end       = "-5"
  dns_nameservers       = "${var.external_dns_nameservers}"
}
