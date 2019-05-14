provider "openstack" {
  version = "~> 1.16"
}
provider "template" {
  version = "~> 2.1"
}

resource "openstack_networking_secgroup_v2" "ssh" {
  name                  = "${var.datacenter}-${var.programme}-${var.env}-secgroup-ssh"
  description           = "SSH Access"
  delete_default_rules  = true
}

resource "openstack_networking_secgroup_rule_v2" "ssh-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Allows inbound SSH connections"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.ssh.id}"
}
