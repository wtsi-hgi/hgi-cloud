# Manages network, subnet, and router
module "build_network" {
  source                = "../../networks/simple"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  external_network_name = "${var.external_network_name}"
  network_name          = "build"
  subnet_cidr           = "${var.build_subnet_cidr}"
  dns_nameservers       = "${var.dns_nameservers}"
}
