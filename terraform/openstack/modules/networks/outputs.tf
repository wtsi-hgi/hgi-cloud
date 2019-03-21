output "main_network_name" {
  value = "${openstack_networking_network_v2.main.name}"

  depends_on = [
    "${openstack_networking_network_v2.main}"
  ]
}

