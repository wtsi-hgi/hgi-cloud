resource "openstack_networking_network_v2" "isolated" {
  name           = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-network-${var.network_name}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "isolated" {
  name            = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-subnet-${var.network_name}"
  network_id      = "${openstack_networking_network_v2.isolated.id}"
  cidr            = "${var.subnet_cidr}"
  dns_nameservers = "${var.dns_nameservers}"
}
