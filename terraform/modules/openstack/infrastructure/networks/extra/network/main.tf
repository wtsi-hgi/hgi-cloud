resource "openstack_networking_network_v2" "extra" {
  name           = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-network-${var.network_name}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "extra" {
  name            = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-subnet-${var.network_name}"
  network_id      = "${openstack_networking_network_v2.extra.id}"
  cidr            = "${var.subnet_cidr}"
  dns_nameservers = "${var.dns_nameservers}"
  allocation_pools {
    start = "${cidrhost(var.subnet_cidr, var.subnet_pool_start)}"
    end   = "${cidrhost(var.subnet_cidr, var.subnet_pool_end)}"
  }
}

resource "openstack_networking_router_interface_v2" "extra" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.extra.id}"
}
