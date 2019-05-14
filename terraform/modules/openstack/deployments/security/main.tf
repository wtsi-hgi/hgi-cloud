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
  source              = "../../infrastructure/keypairs/"
  datacenter          = "${var.datacenter}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  deployment_owner    = "mercury"
  public_key          = "${var.public_key}"
}

module "base_secgroup" {
  source              = "../../infrastructure/secgroups/base/"
  datacenter          = "${var.datacenter}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
}

module "ssh_secgroup" {
  source              = "../../infrastructure/secgroups/ssh/"
  datacenter          = "${var.datacenter}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
}

module "spark_secgroup" {
  source              = "../../infrastructure/secgroups/spark/"
  datacenter          = "${var.datacenter}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
}
