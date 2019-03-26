output "network_name" {
  value = "${openstack_networking_network_v2.isolated.name}"
  depends_on = [
    "${openstack_networking_network_v2.isolated}"
  ]
}

output "network_id" {
  value = "${openstack_networking_network_v2.isolated.id}"
  depends_on = [
    "${openstack_networking_network_v2.isolated}"
  ]
}

output "subnet_name" {
  value = "${openstack_networking_subnet_v2.isolated.name}"
}

output "subnet_id" {
  value = "${openstack_networking_subnet_v2.isolated.id}"
}
