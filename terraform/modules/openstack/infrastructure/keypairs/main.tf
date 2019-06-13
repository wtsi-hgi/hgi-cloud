# provider "openstack" { version = "~> 1.16" }
# provider "template" { version = "~> 2.1" }

resource "openstack_compute_keypair_v2" "keypair" {
  name       = "${var.datacenter}-${var.programme}-${var.env}-keypair-${var.deployment_owner}"
  public_key = "${var.public_key}"
}
