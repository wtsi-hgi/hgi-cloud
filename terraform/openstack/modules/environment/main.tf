# Manages public keys
module "keypairs" {
  source              = "../keypairs/"
  os_release          = "${var.os_release}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  mercury_public_key  = "${var.mercury_public_key}"
}

# Manages network, subnet, and router
module "networking" {
  source                = "../networking/"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  external_network_name = "${var.external_network_name}"
  subnet_cidr           = "${var.subnet_cidr}"
  dns_nameservers       = "${var.dns_nameservers}"
}

# Manages security groups
module "secgroups" {
  source      = "../secgroups/"
  os_release  = "${var.os_release}"
  programme   = "${var.programme}"
  env         = "${var.env}"
}
