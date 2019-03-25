output "instances" {
  value = "${openstack_compute_instance_v2.instance.[*]}"
}
