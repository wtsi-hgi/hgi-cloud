output "sanger_internal_openstack_zeta_hgi_systems_ssh-gateway" {
  value = {
    host = "${openstack_compute_floatingip_associate_v2.sanger_internal_openstack_zeta_hgi_systems_ssh-gateway.floating_ip}"
    user = "${var.image["user"]}"
  }

  depends_on = [
    "${openstack_compute_floatingip_associate_v2.sanger_internal_openstack_zeta_hgi_systems_ssh-gateway}"
  ]
}
