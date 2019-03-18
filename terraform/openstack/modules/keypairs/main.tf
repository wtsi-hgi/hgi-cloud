resource "openstack_compute_keypair_v2" "mercury" {
  name       = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_keypair_mercury"
  public_key = "${var.mercury_public_key}"
}
# resource "openstack_compute_keypair_v2" "jr17" {
#   name       = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_keypair_jr17"
#   public_key = "${var.jr17_public_key}"
# }
