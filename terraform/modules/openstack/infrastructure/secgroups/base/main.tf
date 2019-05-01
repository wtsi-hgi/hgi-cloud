provider "openstack" {
  version = "~> 1.16"
}
provider "template" {
  version = "~> 2.1"
}

resource "openstack_networking_secgroup_v2" "base" {
  name                  = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-base"
  description           = "Base set of secgroups"
}

resource "openstack_networking_secgroup_rule_v2" "icmp-in" {
  direction   = "ingress"
  ethertype   = "IPv4"
  description = "All ICMP in"
  protocol    = "icmp"
  security_group_id = "${openstack_networking_secgroup_v2.base.id}"
}

resource "openstack_networking_secgroup_rule_v2" "icmp-out" {
  direction   = "egress"
  ethertype   = "IPv4"
  description = "All ICMP out"
  protocol    = "icmp"
  security_group_id = "${openstack_networking_secgroup_v2.base.id}"
}

resource "openstack_networking_secgroup_rule_v2" "tcp-local" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "All TCP from local network"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "10.0.0.0/8"
  security_group_id = "${openstack_networking_secgroup_v2.base.id}"
}

resource "openstack_networking_secgroup_rule_v2" "udp-local" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "All UDP from local network"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "10.0.0.0/8"
  security_group_id = "${openstack_networking_secgroup_v2.base.id}"
}

resource "openstack_networking_secgroup_rule_v2" "tcp-out" {
  direction         = "egress"
  ethertype         = "IPv4"
  description       = "All egress TCP"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.base.id}"
}

resource "openstack_networking_secgroup_rule_v2" "udp-out" {
  direction         = "egress"
  ethertype         = "IPv4"
  description       = "All egress UDP"
  protocol          = "udp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.base.id}"
}
