provider "openstack" {
  version = "~> 1.16"
}
provider "template" {
  version = "~> 2.1"
}

data "openstack_networking_secgroup_v2" "secgroup" {
  count = "${length(var.security_groups)}"
  name  = "${element(var.security_groups, count.index)}"
}

data "openstack_networking_network_v2" "network" {
  name  = "${var.datacenter}-${var.programme}-${var.env}-network-${var.network_name}"
}

resource "openstack_networking_port_v2" "port" {
  name                = "${var.datacenter}-${var.programme}-${var.env}-port-${var.network_name}-${var.deployment_name}-${var.deployment_owner}-${var.role_name}-${format("%02d", count.index + 1)}"
  count               = "${var.count}"
  network_id          = "${data.openstack_networking_network_v2.network.id}"
  admin_state_up      = "true"
  security_group_ids  = ["${data.openstack_networking_secgroup_v2.secgroup.*.id}"]
}
