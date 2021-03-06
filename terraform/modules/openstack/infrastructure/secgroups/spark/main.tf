# provider "openstack" { version = "~> 1.16" }
# provider "template" { version = "~> 2.1" }

resource "openstack_networking_secgroup_v2" "spark-master" {
  name                  = "${var.datacenter}-${var.programme}-${var.env}-secgroup-spark-master"
  description           = "Spark Master's Access"
  delete_default_rules  = true
}

resource "openstack_networking_secgroup_v2" "spark-slave" {
  name                  = "${var.datacenter}-${var.programme}-${var.env}-secgroup-spark-slave"
  description           = "Spark Slave's Access"
  delete_default_rules  = true
}

resource "openstack_networking_secgroup_rule_v2" "spark-master-main-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Allows inbound connections to Spark Master"
  protocol          = "tcp"
  port_range_min    = 7077
  port_range_max    = 7077
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.spark-master.id}"
}

resource "openstack_networking_secgroup_rule_v2" "spark-master-web-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Allows inbound connections to Spark Master web interface"
  protocol          = "tcp"
  port_range_min    = 8080
  port_range_max    = 8080
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.spark-master.id}"
}

resource "openstack_networking_secgroup_rule_v2" "spark-master-jupiter-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Allows inbound connections to Jupiter Notebook web interface"
  protocol          = "tcp"
  port_range_min    = 8888
  port_range_max    = 8888
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.spark-master.id}"
}

resource "openstack_networking_secgroup_rule_v2" "spark-master-http-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Allows inbound connections to the http server"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.spark-master.id}"
}

resource "openstack_networking_secgroup_rule_v2" "spark-master-slaves-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Allows inbound connections from any Spark Slave"
  protocol          = "tcp"
  remote_group_id   = "${openstack_networking_secgroup_v2.spark-slave.id}"
  security_group_id = "${openstack_networking_secgroup_v2.spark-master.id}"
}

resource "openstack_networking_secgroup_rule_v2" "spark-slaves-master-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Allows inbound connections from any Spark Master"
  protocol          = "tcp"
  remote_group_id   = "${openstack_networking_secgroup_v2.spark-master.id}"
  security_group_id = "${openstack_networking_secgroup_v2.spark-slave.id}"
}

resource "openstack_networking_secgroup_rule_v2" "spark-slaves-slaves-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Allows inbound connections from any Spark Slave"
  protocol          = "tcp"
  remote_group_id   = "${openstack_networking_secgroup_v2.spark-slave.id}"
  security_group_id = "${openstack_networking_secgroup_v2.spark-slave.id}"
}
