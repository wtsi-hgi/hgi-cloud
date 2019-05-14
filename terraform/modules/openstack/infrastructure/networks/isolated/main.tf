provider "openstack" {
  version = "~> 1.16"
}
provider "template" {
  version = "~> 2.1"
}

resource "openstack_networking_network_v2" "isolated" {
  name           = "${var.datacenter}-${var.programme}-${var.env}-network-${var.deployment_owner}-${var.network_name}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "isolated" {
  name            = "${var.datacenter}-${var.programme}-${var.env}-subnet-${var.deployment_owner}-${var.network_name}"
  network_id      = "${openstack_networking_network_v2.isolated.id}"
  cidr            = "${var.subnet_cidr}"
  dns_nameservers = "${var.dns_nameservers}"
}
