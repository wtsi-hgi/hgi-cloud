output "instance_id" {
  value = "${openstack_compute_instance_v2.instance.*.id}"
}
