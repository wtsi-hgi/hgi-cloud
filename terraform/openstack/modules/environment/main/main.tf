# Manages network, subnet, and router
module "main_network" {
  source                = "../networks/simple"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  external_network_name = "${var.external_network_name}"
  network_name          = "main"
  subnet_cidr           = "${var.main_subnet_cidr}"
  dns_nameservers       = "${var.dns_nameservers}"
}

module "workstation_subnet" {
  source                = "../networks/extra_subnet/"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  subnet_name           = "workstations"
  subnet_cidr           = "${var.workstations_subnet_cidr}"
  network_id            = "${module.main_network.network_id}"
  router_id             = "${module.main_network.router_id}"
  dns_nameservers       = "${var.dns_nameservers}"
}
