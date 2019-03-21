###############################################################################
# Configure Networks, Subnets, & Routers
###############################################################################
data "openstack_networking_network_v2" "external" {
  name     = "${var.external_network_name}"
  external = true
}

resource "openstack_networking_network_v2" "main" {
  name           = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-network-main"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "main" {
  name            = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-subnet-main"
  network_id      = "${openstack_networking_network_v2.main.id}"
  cidr            = "${var.subnet_main_cidr}"
  dns_nameservers = "${var.dns_nameservers}"
}

resource "openstack_networking_subnet_v2" "main" {
  name            = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-subnet-workstations"
  network_id      = "${openstack_networking_network_v2.main.id}"
  cidr            = "${var.subnet_workstations_cidr}"
  dns_nameservers = "${var.dns_nameservers}"
}

resource "openstack_networking_router_v2" "main" {
  count               = "1"
  name                = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-router-main"
  external_network_id = "${data.openstack_networking_network_v2.external.id}"
}

resource "openstack_networking_router_interface_v2" "main" {
  router_id = "${openstack_networking_router_v2.main.id}"
  subnet_id = "${openstack_networking_subnet_v2.main.id}"
}

resource "openstack_networking_router_interface_v2" "workstations" {
  router_id = "${openstack_networking_router_v2.main.id}"
  subnet_id = "${openstack_networking_subnet_v2.workstations.id}"
}


resource "openstack_networking_network_v2" "build" {
  name           = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-network-build"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "build" {
  name            = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-subnet-build"
  network_id      = "${openstack_networking_network_v2.build.id}"
  cidr            = "${var.subnet_build_cidr}"
  dns_nameservers = "${var.dns_nameservers}"
}

resource "openstack_networking_router_v2" "build" {
  count               = "1"
  name                = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-router-build"
  external_network_id = "${data.openstack_networking_network_v2.external.id}"
}

resource "openstack_networking_router_interface_v2" "build" {
  router_id = "${openstack_networking_router_v2.build.id}"
  subnet_id = "${openstack_networking_subnet_v2.build.id}"
}
