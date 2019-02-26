output "sanger_internal_openstack_zeta_hgi_systems_keypairs_output" {
  value = {
    mercury = "${openstack_compute_keypair_v2.mercury.id}"
    jr17    = "${openstack_compute_keypair_v2.jr17.id}"
  }

  depends_on = [
    "${openstack_compute_keypair_v2.mercury}",
    "${openstack_compute_keypair_v2.jr17}"
  ]
}
