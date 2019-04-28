###############################################################################
# Configure Networks, Subnets, & Routers
###############################################################################
data "openstack_networking_network_v2" "external" {
  name     = "${var.external_network_name}"
  external = true
}

resource "openstack_networking_router_v2" "main" {
  name                = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-router-${var.network_name}"
  external_network_id = "${data.openstack_networking_network_v2.external.id}"
}

module "main_network" {
  source                = "../extra/network/"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  subnet_cidr           = "${var.subnet_cidr}"
  subnet_pool_start     = "${var.subnet_pool_start}"
  subnet_pool_end       = "${var.subnet_pool_end}"
  network_name          = "${var.network_name}"
  router_id             = "${openstack_networking_router_v2.main.id}"
  dns_nameservers       = "${var.dns_nameservers}"
}
