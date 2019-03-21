module "main_environment" {
  source                = "main/"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  external_network_name = "${var.external_network_name}"
  subnet_cidr           = "${var.main_subnet_cidr}"
  dns_nameservers       = "${var.dns_nameservers}"
}
