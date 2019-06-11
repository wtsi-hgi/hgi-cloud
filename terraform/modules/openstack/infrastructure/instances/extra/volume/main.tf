provider "openstack" {
  version = "~> 1.16"
}
provider "template" {
  version = "~> 2.1"
}

resource "openstack_blockstorage_volume_v2" "extra" {
  name          = "${var.datacenter}-${var.programme}-${var.env}-volume-${var.volume_name}-${var.deployment_owner}-${var.deployment_name}-${var.role_name}-${format("%02d", count.index + 1)}"
  size          = "${var.size}"
  count         = "${var.count}"
}

resource "openstack_compute_volume_attach_v2" "attachment" {
  count         = "${var.count}"
  instance_id   = "${element(var.instance_ids, count.index)}"
  volume_id     = "${element(openstack_blockstorage_volume_v2.extra.*.id, count.index)}"
}
