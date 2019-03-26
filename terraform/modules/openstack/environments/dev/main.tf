provider "openstack" {
  version = "~> 1.16"
}

module "common_environment" {
  source                    = "../common/"
  os_release                = "${var.os_release}"
  programme                 = "${var.programme}"
  env                       = "${var.env}"
  mercury_public_key        = "${var.mercury_public_key}"
}

module "spark_environment" {
  source                    = "../spark/"
  os_release                = "${var.os_release}"
  programme                 = "${var.programme}"
  env                       = "${var.env}"
  count                     = "${var.count}"
  image_name                = "${var.image_name}"
  flavor_name               = "${var.flavor_name}"
  affinity                  = "${var.affinity}"
  external_network_name     = "${var.external_network_name}"
  spark_subnet_cidr         = "${var.spark_subnet_cidr}"
  workstations_subnet_cidr  = "${var.workstations_subnet_cidr}"
  management_subnet_cidr    = "${var.management_subnet_cidr}"
  consensus_subnet_cidr     = "${var.consensus_subnet_cidr}"
  dns_nameservers           = "${var.dns_nameservers}"
  depends_on                = ["${module.common_environment.mercury_keypair}"]
}

module "build_environment" {
  source                    = "../build/"
  os_release                = "${var.os_release}"
  programme                 = "${var.programme}"
  env                       = "${var.env}"
  external_network_name     = "${var.external_network_name}"
  build_subnet_cidr         = "${var.build_subnet_cidr}"
  dns_nameservers           = "${var.dns_nameservers}"
  depends_on                = ["${module.common_environment.mercury_keypair}"]
}
