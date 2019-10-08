output "network_id" {
  value = "${data.openstack_networking_network_v2.network.id}"
}

output "pool_id" {
  value = "${openstack_lb_pool_v2.http.id}"
}
