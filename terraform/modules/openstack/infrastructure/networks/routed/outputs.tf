output "network_name" {
  value = "${module.main_network.network_name}"
}

output "network_id" {
  value = "${module.main_network.network_id}"
}

output "router_id" {
  value = "${openstack_networking_router_v2.main.id}"
  depends_on = [
    "${openstack_networking_network_v2.main}"
  ]
}

output "subnet_id" {
  value = "${module.main_network.subnet_id}"
}
