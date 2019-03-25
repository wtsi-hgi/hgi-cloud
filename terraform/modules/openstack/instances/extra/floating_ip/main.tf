resource "openstack_compute_floatingip_v2" "pool" {
  pool  = "${var.floating_ip_pool}"
  count = "${var.count}"
}

resource "openstack_compute_floatingip_associate_v2" "associate" {
  count = "${var.count}"
  floating_ip = "${element(openstack_compute_floatingip_v2.pool.*.address, count.index)}"
  instance_id = "${element(var.instances[*].id, count.index)}"
}
