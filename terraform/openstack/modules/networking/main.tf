###############################################################################
# Configure Networks, Subnets, & Routers
###############################################################################
data "openstack_networking_network_v2" "external" {
  name     = "${var.external_network_name}"
  external = true
}
resource "openstack_networking_network_v2" "main" {
  name           = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_network_main"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "main" {
  name            = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_subnet_main"
  network_id      = "${openstack_networking_network_v2.main.id}"
  cidr            = "${var.subnet_cidr}"
  dns_nameservers = "${var.dns_nameservers}"
}

resource "openstack_networking_router_v2" "main" {
  count               = "1"
  name                = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_router_main"
  external_network_id = "${data.openstack_networking_network_v2.external.id}"
}

resource "openstack_networking_router_interface_v2" "main" {
  router_id = "${openstack_networking_router_v2.main.id}"
  subnet_id = "${openstack_networking_subnet_v2.main.id}"
}
