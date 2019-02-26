###############################################################################
# Look up external network id from name
###############################################################################
data "openstack_networking_network_v2" "sanger_internal_openstack_zeta_hgi_systems_network_external" {
  name     = "${var.external_network_name}"
  external = true
}

###############################################################################
# Configure Networks, Subnets, & Routers
###############################################################################
resource "openstack_networking_network_v2" "sanger_internal_openstack_zeta_hgi_systems_network_main" {
  provider       = "openstack"
  name           = "sanger_internal_openstack_zeta_${var.region}_${var.env}_hgi_systems_network_main"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "sanger_internal_openstack_zeta_hgi_systems_subnet_main" {
  provider        = "openstack"
  name            = "sanger_internal_openstack_zeta_${var.region}_${var.env}_hgi_systems_subnet_main"
  network_id      = "${openstack_networking_network_v2.sanger_internal_openstack_zeta_hgi_systems_network_main.id}"
  cidr            = "${var.subnet}"
  ip_version      = 4
  dns_nameservers = "${var.dns_nameservers}"
  host_routes     = "${var.host_routes}"
  gateway_ip      = "${var.gateway_ip}"
}

resource "openstack_networking_router_v2" "sanger_internal_openstack_zeta_hgi_systems_router_main" {
  count               = "1"
  provider            = "openstack"
  name                = "sanger_internal_openstack_zeta_${var.region}_${var.env}_hgi_systems_router_main"
  external_network_id = "${data.openstack_networking_network_v2.sanger_internal_openstack_zeta_hgi_systems_network_external.id}"
}

resource "openstack_networking_router_interface_v2" "sanger_internal_openstack_zeta_hgi_systems_router_interface_main" {
  provider  = "openstack"
  router_id = "${openstack_networking_router_v2.main_ext.id}"
  subnet_id = "${openstack_networking_subnet_v2.main.id}"
}

