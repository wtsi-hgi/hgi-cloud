provider "openstack" {
  version = "~> 1.16"
}
provider "template" {
  version = "~> 2.1"
}

resource "openstack_networking_secgroup_v2" "base" {
  name                  = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-base"
  description           = "Base set of secgroups"
  delete_default_rules  = true
}

resource "openstack_networking_secgroup_rule_v2" "icmp-in" {
  direction   = "ingress"
  ethertype   = "IPv4"
  description = "All ICMP in"
  protocol    = "icmp"
  security_group_id = "${openstack_networking_secgroup_v2.base.id}"
}

resource "openstack_networking_secgroup_rule_v2" "tcp-local-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "All TCP from local network"
  protocol          = "tcp"
  remote_ip_prefix  = "10.0.0.0/8"
  security_group_id = "${openstack_networking_secgroup_v2.base.id}"
}

resource "openstack_networking_secgroup_rule_v2" "udp-local-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "All UDP from local network"
  protocol          = "udp"
  remote_ip_prefix  = "10.0.0.0/8"
  security_group_id = "${openstack_networking_secgroup_v2.base.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ipv4-out" {
  direction = "egress"
  ethertype = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.base.id}"
}

resource "openstack_networking_secgroup_rule_v2" "ipv6-out" {
  direction = "egress"
  ethertype = "IPv6"
  security_group_id = "${openstack_networking_secgroup_v2.base.id}"
}
