###############################################################################
# Configure Networks, Subnets, & Routers
###############################################################################
data "openstack_networking_network_v2" "external" {
  name     = "${var.external_network_name}"
  external = true
}

resource "openstack_networking_network_v2" "main" {
  name           = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-network-${var.network_name}"
  admin_state_up = "true"
}

resource "openstack_networking_router_v2" "main" {
  count               = "1"
  name                = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-router-${var.network_name}"
  external_network_id = "${data.openstack_networking_network_v2.external.id}"
}

module "main_subnet" {
  source                = "../extra/subnet/"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  subnet_cidr           = "${var.subnet_cidr}"
  subnet_name           = "${var.network_name}"
  router_id             = "${openstack_networking_router_v2.main.id}"
  network_id            = "${openstack_networking_network_v2.main.id}"
  dns_nameservers       = "${var.dns_nameservers}"
}
