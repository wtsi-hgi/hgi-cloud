# Manages public keys
module "keypairs" {
  source              = "../keypairs/"
  env                 = "${var.env}"
  os_release          = "${var.os_release}"
  mercury_public_key  = "${var.mercury_public_key}"
}

# Manages network, subnet, and router
module "networking" {
  source                = "../networking/"
  env                   = "${var.env}"
  os_release            = "${var.os_release}"
  external_network_name = "${var.external_network_name}"
  subnet_cidr           = "${var.subnet_cidr}"
  dns_nameservers       = "${var.dns_nameservers}"
}

# Manages security groups
module "secgroups" {
  source      = "../secgroups/"
  env         = "${var.env}"
  os_release  = "${var.os_release}"
}
