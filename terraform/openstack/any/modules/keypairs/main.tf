resource "openstack_compute_keypair_v2" "mercury" {
  name       = "uk-sanger-internal-openstack-${var.os_release}-hgi-${var.env}-keypair-mercury"
  public_key = "${var.mercury_public_key}"
}
