# provider "openstack" { version = "~> 1.16" }
# provider "template" { version = "~> 2.1" }

module "standard_volume" {
  source              = "../../../volumes/standard"
  datacenter          = "${var.datacenter}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  deployment_name     = "${var.deployment_name}"
  deployment_owner    = "${var.deployment_owner}"
  volume_name         = "${var.volume_name}"
  size                = "${var.size}"
  count               = "${var.count}"
}

resource "openstack_compute_volume_attach_v2" "attachment" {
  count       = "${var.count}"
  instance_id = "${element(var.instance_ids, count.index)}"
  volume_id   = "${element(module.standard_volume.volume_ids, count.index)}"
}
