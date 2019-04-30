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

module "keypairs" {
  source      = "../../infrastructure/keypairs/"
  os_release  = "${var.os_release}"
  programme   = "${var.programme}"
  env         = "${var.env}"
  public_key  = "${var.public_key}"
}

module "base_secgroup" {
  source      = "../../infrastructure/secgroups/base/"
  os_release  = "${var.os_release}"
  programme   = "${var.programme}"
  env         = "${var.env}"
}

module "ssh_secgroup" {
  source      = "../../infrastructure/secgroups/ssh/"
  os_release  = "${var.os_release}"
  programme   = "${var.programme}"
  env         = "${var.env}"
}

module "spark_secgroup" {
  source      = "../../infrastructure/secgroups/spark/"
  os_release  = "${var.os_release}"
  programme   = "${var.programme}"
  env         = "${var.env}"
}
