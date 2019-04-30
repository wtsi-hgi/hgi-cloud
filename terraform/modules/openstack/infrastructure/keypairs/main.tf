provider "openstack" {
  version = "~> 1.16"
}
provider "template" {
  version = "~> 2.1"
}

resource "openstack_compute_keypair_v2" "mercury" {
  name       = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-keypair-mercury"
  public_key = "${var.public_key}"
}
