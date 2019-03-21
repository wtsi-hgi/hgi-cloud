output "subnet_id" {
  value = "${openstack_networking_subnet_v2.main.id}"
  depends_on = [
    "${openstack_networking_subnet_v2.main}"
  ]
}
