provider "openstack" {
  version = "~> 1.16"
}
provider "template" {
  version = "~> 2.1"
}

locals {
  metadata = {
    datacentre          = "uk-sanger-internal-openstack"
    datacenter          = "${var.datacenter}"
    programme           = "${var.programme}"
    env                 = "${var.env}"
    deployment_name     = "${var.deployment_name}"
    deployment_owner    = "${var.deployment_owner}"
    deployment_color    = "${var.deployment_color}"
    role_name           = "${var.role_name}"
    role_version        = "${var.role_version}"
  }
}

data "openstack_images_image_v2" "base_image" {
  name = "${var.image_name}"
  most_recent = true
}

resource "openstack_compute_servergroup_v2" "servergroup" {
  name      = "${var.datacenter}-${var.programme}-${var.env}-servergroup-${var.deployment_name}-${var.deployment_owner}-${var.role_name}"
  policies  = ["${var.affinity}"]
}

module "user_data" {
  source        = "../extra/user_data/"
  count         = "${var.count}"
  template_vars = "${merge(local.metadata, map("extra_user_data", jsonencode(var.extra_user_data), "vault_password", var.vault_password))}"
}

module "network_port" {
  source          = "../extra/standard_ip_port/"
  datacenter      = "${var.datacenter}"
  programme       = "${var.programme}"
  env             = "${var.env}"
  network_name    = "${var.network_name}"
  deployment_name = "${var.deployment_name}"
  role_name       = "${var.role_name}"
  security_groups = "${var.security_groups}"
  count           = "${var.count}"
}

resource "openstack_compute_instance_v2" "instance" {
  name                = "${var.datacenter}-${var.programme}-${var.env}-instance-${var.deployment_name}-${var.deployment_owner}-${var.role_name}-${format("%02d", count.index + 1)}"
  count               = "${var.count}"
  flavor_name         = "${var.flavor_name}"
  key_pair            = "${var.key_pair}"
  stop_before_destroy = true
  security_groups     = "${var.security_groups}"
  metadata            = "${local.metadata}"
  user_data           = "${element(module.user_data.rendered, count.index)}"

  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.servergroup.id}"
  }

  block_device {
    uuid                  = "${data.openstack_images_image_v2.base_image.id}"
    source_type           = "image"
    volume_size           = "${var.volume_size}"
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    port = "${element(module.network_port.port_id, count.index)}"
  }
}
