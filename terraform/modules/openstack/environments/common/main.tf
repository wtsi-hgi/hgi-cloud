# Manages public keys
provider "openstack" {
  version = "~> 1.16"
}

module "keypairs" {
  source              = "../../infrastructure/keypairs/"
  os_release          = "${var.os_release}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  mercury_public_key  = "${var.mercury_public_key}"
}

# Manages security groups
module "secgroups" {
  source      = "../../infrastructure/secgroups/"
  os_release  = "${var.os_release}"
  programme   = "${var.programme}"
  env         = "${var.env}"
}
