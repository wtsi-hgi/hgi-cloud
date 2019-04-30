provider "openstack" {
  version = "~> 1.16"
}
provider "template" {
  version = "~> 2.1"
}

resource "openstack_compute_floatingip_v2" "pool" {
  pool  = "${var.floating_ip_pool}"
  count = "${var.instances_count}"
}

resource "openstack_compute_floatingip_associate_v2" "associate" {
  count = "${var.instances_count}"
  floating_ip = "${element(openstack_compute_floatingip_v2.pool.*.address, count.index)}"
  instance_id = "${element(var.instance_ids, count.index)}"
}
