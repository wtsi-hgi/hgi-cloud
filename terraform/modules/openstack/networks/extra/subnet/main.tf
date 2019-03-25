resource "openstack_networking_subnet_v2" "extra" {
  name            = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-subnet-${var.subnet_name}"
  network_id      = "${var.network_id}"
  cidr            = "${var.subnet_cidr}"
  dns_nameservers = "${var.dns_nameservers}"
}

resource "openstack_networking_router_interface_v2" "extra" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.extra.id}"
}

