output "attached" {
  value = "${openstack_compute_volume_attach_v2.attachment.*.volume_id}"
}

