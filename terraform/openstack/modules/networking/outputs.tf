output "sanger_internal_openstack_zeta_hgi_networking" {
  value = {
    subnetpool_id   = "${openstack_networking_subnetpool_v2.uk_sanger_internal_openstack_zeta_hgi_subnetpool_main.id}"
    subnetpool_name = "${openstack_networking_subnetpool_v2.uk_sanger_internal_openstack_zeta_hgi_subnetpool_main.name}"
  }

  depends_on = [
    "${openstack_networking_subnetpool_v2.uk_sanger_internal_openstack_zeta_hgi_subnetpool_main}",
  ]
}
