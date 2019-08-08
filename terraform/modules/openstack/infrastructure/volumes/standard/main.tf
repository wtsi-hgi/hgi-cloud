# provider "openstack" { version = "~> 1.16" }
# provider "template" { version = "~> 2.1" }

resource "openstack_blockstorage_volume_v2" "volume" {
  name        = "${var.datacenter}-${var.programme}-${var.env}-volume-${var.deployment_owner}-${var.deployment_name}-${var.volume_name}-${format("%02d", count.index + 1)}"
  size        = "${var.size}"
  count       = "${var.count}"
}

