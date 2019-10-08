
# provider "openstack" { version = "~> 1.16" }



data "openstack_networking_network_v2" "network" {

  name = "${var.datacenter}-${var.programme}-${var.env}-network-${var.network_name}"

}

data "openstack_networking_subnet_v2" "subnet" {

  name = "${var.datacenter}-${var.programme}-${var.env}-subnet-${var.network_name}"

}

data "openstack_networking_secgroup_v2" "secgroup" {
  count = "${length(var.security_groups)}"
  name  = "${element(var.security_groups, count.index)}"
}




# Create a load balancer
resource "openstack_lb_loadbalancer_v2" "http" {
	
	name               = "${var.datacenter}-${var.programme}-${var.env}-lb-${var.network_name}-${var.deployment_owner}-${var.deployment_name}" 
  vip_subnet_id      = "${data.openstack_networking_subnet_v2.subnet.id}"
  security_group_ids = ["${data.openstack_networking_secgroup_v2.secgroup.*.id}"]
}

# Create a listener

resource "openstack_lb_listener_v2" "http" {

  name            = "${var.datacenter}-${var.programme}-${var.env}-lblistener-${var.network_name}-${var.deployment_owner}-${var.deployment_name}"
  protocol        = "${var.protocol}"
  protocol_port   = "${var.listener_port}"
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.http.id}"
  # depends_on      = ["${openstack_lb_loadbalancer_v2.http}"]
}

# Set mthod for load balanc charge between instance 

resource "openstack_lb_pool_v2" "http" {

  name          = "${var.datacenter}-${var.programme}-${var.env}-lbpool-${var.network_name}-${var.deployment_owner}-${var.deployment_name}"
  protocol      = "${var.protocol}"
  lb_method     = "${var.lb_method}"
  listener_id   = "${openstack_lb_listener_v2.http.id}"
  # depends_on    = ["${openstack_lb_listener_v2.http}"]
  
}


# Add multiple instances to pool

resource "openstack_lb_member_v2" "http" {

  count         = "${var.member_count}"
  address       = "${element(var.instance_access_ip_v4s, count.index)}"
  protocol_port = 8080
  pool_id       = "${openstack_lb_pool_v2.http.id}"
  subnet_id     = "${data.openstack_networking_subnet_v2.subnet.id}"
  # depends_on    = ["${openstack_lb_pool_v2.http}"]
  
  
}




# Create health monitor for check services instances status

# resource "openstack_lb_monitor_v2" "http" {
#   name        = "monitor_http"
#   pool_id     = openstack_lb_pool_v2.http.id
#   type        = "${var.port}"
#   delay       = 2
#   timeout     = 2
#   max_retries = 2
#   depends_on  = [openstack_lb_member_v2.http]
# }

