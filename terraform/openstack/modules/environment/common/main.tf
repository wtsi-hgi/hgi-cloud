# Manages public keys
module "keypairs" {
  source              = "../keypairs/"
  os_release          = "${var.os_release}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  mercury_public_key  = "${var.mercury_public_key}"
}

# Manages security groups
module "secgroups" {
  source      = "../secgroups/"
  os_release  = "${var.os_release}"
  programme   = "${var.programme}"
  env         = "${var.env}"
}
