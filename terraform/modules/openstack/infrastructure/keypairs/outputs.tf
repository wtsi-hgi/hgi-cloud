output "mercury" {
  value = "${openstack_compute_keypair_v2.keypair.id}"
  depends_on = ["${openstack_compute_keypair_v2.keypair}"]
}
