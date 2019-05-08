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
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  external_network_name = "${var.external_network_name}"
  network_name          = "main"
  subnet_cidr           = "${var.main_subnet_cidr}"
  dns_nameservers       = "${var.local_dns_nameservers}"
}

module "build_network" {
  source                = "../../infrastructure/networks/routed"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  external_network_name = "${var.external_network_name}"
  network_name          = "build"
  subnet_cidr           = "${var.build_subnet_cidr}"
  dns_nameservers       = "${var.external_dns_nameservers}"
}

module "workstations_network" {
  source                = "../../infrastructure/networks/extra/network/"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  subnet_cidr           = "${var.workstations_subnet_cidr}"
  network_name          = "workstations"
  router_id             = "${module.main_network.router_id}"
  dns_nameservers       = "${var.local_dns_nameservers}"
}

module "management_network" {
  source                = "../../infrastructure/networks/extra/network/"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  subnet_cidr           = "${var.management_subnet_cidr}"
  network_name          = "management"
  router_id             = "${module.main_network.router_id}"
  subnet_pool_end       = "-5"
  dns_nameservers       = "${var.external_dns_nameservers}"
}

module "pet_network" {
  source                = "../../infrastructure/networks/routed"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  external_network_name = "${var.external_network_name}"
  network_name          = "pet"
  subnet_cidr           = "${var.pet_subnet_cidr}"
  # The "+ 2" is because the pool range is inclusive, and you have to exclude
  # the broadcast address as well. 
  subnet_pool_end       = "${-1 * (var.pet_clusters + 2)}"
  dns_nameservers       = "${var.external_dns_nameservers}"
}
