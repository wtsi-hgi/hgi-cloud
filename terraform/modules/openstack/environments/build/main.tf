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

module "build_network" {
  source                = "../../infrastructure/networks/routed"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  external_network_name = "${var.external_network_name}"
  network_name          = "build"
  subnet_cidr           = "${var.build_subnet_cidr}"
  dns_nameservers       = "${var.dns_nameservers}"
}