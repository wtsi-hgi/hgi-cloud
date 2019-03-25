output "subnet_id" {
  value = "${openstack_networking_subnet_v2.extra.id}"
  depends_on = [
    "${openstack_networking_subnet_v2.extra}"
  ]
}
