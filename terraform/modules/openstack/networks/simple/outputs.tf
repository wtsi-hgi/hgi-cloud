output "network_name" {
  value = "${openstack_networking_network_v2.main.name}"
  depends_on = [
    "${openstack_networking_network_v2.main}"
  ]
}

output "network_id" {
  value = "${openstack_networking_network_v2.main.id}"
  depends_on = [
    "${openstack_networking_network_v2.main}"
  ]
}

output "router_id" {
  value = "${openstack_networking_router_v2.main.id}"
  depends_on = [
    "${openstack_networking_network_v2.main}"
  ]
}

output "subnet_id" {
  value = "${module.main_subnet.subnet_id}"
}
