output "network_name" {
  value = "${openstack_networking_network_v2.extra.name}"
  depends_on = [ "${openstack_networking_network_v2.extra}" ]
}

output "network_id" {
  value = "${openstack_networking_network_v2.extra.id}"
  depends_on = [ "${openstack_networking_network_v2.extra}" ]
}

output "subnet_id" {
  value = "${openstack_networking_subnet_v2.extra.id}"
  depends_on = [ "${openstack_networking_subnet_v2.extra}" ]
}
