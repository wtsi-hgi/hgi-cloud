# provider "openstack" { version = "~> 1.16" }

# Open Protocols and Ports Between the Hosts[1]
#
# The following ports must be available. On some systems, these ports
# are open by default.
#
# * TCP port 2377 for cluster management communications
# * TCP and UDP port 7946 for communication among nodes
# * UDP port 4789 for overlay network traffic
#
# If you plan on creating an overlay network with encryption (--opt
# encrypted), you also need to ensure ip protocol 50 (ESP) traffic is
# allowed.
#
# [1] https://docs.docker.com/engine/swarm/swarm-tutorial/#open-protocols-and-ports-between-the-hosts

resource "openstack_networking_secgroup_v2" "docker_swarm-manager" {
  name                  = "${var.datacenter}-${var.programme}-${var.env}-secgroup-docker_swarm-manager"
  description           = "Docker Swarm Manager Access"
  delete_default_rules  = true
}

resource "openstack_networking_secgroup_v2" "docker_swarm-worker" {
  name                  = "${var.datacenter}-${var.programme}-${var.env}-secgroup-docker_swarm-worker"
  description           = "Docker Swarm Worker Access"
  delete_default_rules  = true
}

resource "openstack_networking_secgroup_v2" "docker_swarm-web_app" {
  name                  = "${var.datacenter}-${var.programme}-${var.env}-secgroup-docker_swarm-web_app"
  description           = "The security group for docker swarm services. Ports exposed by any service deployed to the swarm must adhere to this group's rules for it to be able to serve external requests."
  delete_default_rules  = false
}

# FIXME Do we need "manager to worker" rules in any of the following planes?

# Management plane

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-manager-manager-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Cluster management and Raft synchronisation (manager to manager)"
  protocol          = "tcp"
  port_range_min    = 2377
  port_range_max    = 2377
  remote_group_id   = "${openstack_networking_secgroup_v2.docker_swarm-manager.id}"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-manager.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-worker-manager-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Cluster management and Raft synchronisation (worker to manager)"
  protocol          = "tcp"
  port_range_min    = 2377
  port_range_max    = 2377
  remote_group_id   = "${openstack_networking_secgroup_v2.docker_swarm-worker.id}"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-manager.id}"
}

# Control plane

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-manager-manager-control-tcp-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Control plane TCP (manager to manager)"
  protocol          = "tcp"
  port_range_min    = 7946
  port_range_max    = 7946
  remote_group_id   = "${openstack_networking_secgroup_v2.docker_swarm-manager.id}"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-manager.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-worker-manager-control-tcp-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Control plane TCP (worker to manager)"
  protocol          = "tcp"
  port_range_min    = 7946
  port_range_max    = 7946
  remote_group_id   = "${openstack_networking_secgroup_v2.docker_swarm-worker.id}"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-manager.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-worker-worker-control-tcp-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Control plane TCP (worker to worker)"
  protocol          = "tcp"
  port_range_min    = 7946
  port_range_max    = 7946
  remote_group_id   = "${openstack_networking_secgroup_v2.docker_swarm-worker.id}"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-worker.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-manager-manager-control-udp-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Control plane UDP (manager to manager)"
  protocol          = "udp"
  port_range_min    = 7946
  port_range_max    = 7946
  remote_group_id   = "${openstack_networking_secgroup_v2.docker_swarm-manager.id}"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-manager.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-worker-manager-control-udp-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Control plane UDP (worker to manager)"
  protocol          = "udp"
  port_range_min    = 7946
  port_range_max    = 7946
  remote_group_id   = "${openstack_networking_secgroup_v2.docker_swarm-worker.id}"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-manager.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-worker-worker-control-udp-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Control plane UDP (worker to worker)"
  protocol          = "udp"
  port_range_min    = 7946
  port_range_max    = 7946
  remote_group_id   = "${openstack_networking_secgroup_v2.docker_swarm-worker.id}"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-worker.id}"
}

# Data plane (overlay VXLAN)

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-manager-manager-data-udp-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Data plane UDP (manager to manager)"
  protocol          = "udp"
  port_range_min    = 4789
  port_range_max    = 4789
  remote_group_id   = "${openstack_networking_secgroup_v2.docker_swarm-manager.id}"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-manager.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-worker-manager-data-udp-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Data plane UDP (worker to manager)"
  protocol          = "udp"
  port_range_min    = 4789
  port_range_max    = 4789
  remote_group_id   = "${openstack_networking_secgroup_v2.docker_swarm-worker.id}"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-manager.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-worker-worker-data-udp-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Data plane UDP (worker to worker)"
  protocol          = "udp"
  port_range_min    = 4789
  port_range_max    = 4789
  remote_group_id   = "${openstack_networking_secgroup_v2.docker_swarm-worker.id}"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-worker.id}"
}

# Security plane

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-manager-manager-security-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Security plane ESP (manager to manager)"
  protocol          = "esp"
  remote_group_id   = "${openstack_networking_secgroup_v2.docker_swarm-manager.id}"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-manager.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-worker-manager-security-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Security plane ESP (worker to manager)"
  protocol          = "esp"
  remote_group_id   = "${openstack_networking_secgroup_v2.docker_swarm-worker.id}"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-manager.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-worker-worker-security-in" {
  direction         = "ingress"
  ethertype         = "IPv4"
  description       = "Security plane ESP (worker to worker)"
  protocol          = "esp"
  remote_group_id   = "${openstack_networking_secgroup_v2.docker_swarm-worker.id}"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-worker.id}"
}

# docker_swarm-web_app settings

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-secgroup_1" {
  direction         = "egress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3476
  port_range_max    = 3476
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-web_app.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-secgroup_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 90
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-web_app.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-secgroup_3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-web_app.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-secgroup_4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3000
  port_range_max    = 3000
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-web_app.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-secgroup_5" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3001
  port_range_max    = 3001
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-web_app.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-secgroup_6" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3444
  port_range_max    = 3444
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-web_app.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-secgroup_7" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3476
  port_range_max    = 3476
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-web_app.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-secgroup_8" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3838
  port_range_max    = 3838
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-web_app.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-secgroup_9" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8080
  port_range_max    = 8080
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-web_app.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-secgroup_10" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8888
  port_range_max    = 8888
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-web_app.id}"
}

resource "openstack_networking_secgroup_rule_v2" "docker_swarm-secgroup_11" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9000
  port_range_max    = 9000
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.docker_swarm-web_app.id}"
}
