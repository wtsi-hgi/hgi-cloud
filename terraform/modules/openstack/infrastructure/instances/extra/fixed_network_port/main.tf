data "openstack_networking_secgroup_v2" "secgroup" {
  count = "${length(var.security_groups)}"
  name  = "${element(var.security_groups, count.index)}"
}

data "openstack_networking_network_v2" "network" {
  name  = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-network-${var.network_name}"
}

data "openstack_networking_subnet_v2" "subnet" {
  name  = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-network-${var.network_name}"
}

resource "openstack_networking_port_v2" "port" {
  name                = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-port-${var.deployment_name}-${var.role_name}-${var.network_name}"
  count               = "${var.count}"
  network_id          = "${data.openstack_networking_network_v2.network.id}"
  admin_state_up      = "true"
  security_group_ids  = "${data.openstack_networking_secgroup_v2.secgroup.*.id}"
  fixed_ip            = {
    subnet_id   = "${data.openstack_networking_subnet_v2.subnet.id}"
    ip_addesses = "${var.ip_addesses}"
  }
}
