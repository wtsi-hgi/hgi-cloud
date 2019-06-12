provider "openstack" {
  version = "~> 1.16"
}
provider "template" {
  version = "~> 2.1"
}

resource "openstack_compute_volume_attach_v2" "attachment" {
  count       = "${var.count}"
  instance_id = "${element(var.instance_ids, count.index)}"
  volume_id   = "${element(var.volume_ids, count.index)}"
}
