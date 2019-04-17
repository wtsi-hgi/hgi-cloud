locals {
  metadata = {
    datacentre          = "uk-sanger-internal-openstack"
    os_release          = "${var.os_release}"
    programme           = "${var.programme}"
    env                 = "${var.env}"
    deployment_name     = "${var.deployment_name}"
    deployment_version  = "${var.deployment_version}"
    deployment_color    = "${var.deployment_color}"
    role_name           = "${var.role_name}"
    role_version        = "${var.role_version}"
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh.tpl")}"
  vars = {
    datacentre          = "${local.metadata["datacentre"]}"
    os_release          = "${local.metadata["os_release"]}"
    programme           = "${local.metadata["programme"]}"
    env                 = "${local.metadata["env"]}"
    deployment_name     = "${local.metadata["deployment_name"]}"
    deployment_version  = "${local.metadata["deployment_version"]}"
    deployment_color    = "${local.metadata["deployment_color"]}"
    role_name           = "${local.metadata["role_name"]}"
    role_version        = "${local.metadata["role_version"]}"
    count               = "00"
    vault_password      = "${var.vault_password}"
  }
}

data "openstack_images_image_v2" "base_image" {
  name = "${var.image_name}"
  most_recent = true
}

resource "openstack_compute_servergroup_v2" "servergroup" {
  name      = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-servergroup-${var.deployment_name}-${var.role_name}"
  policies  = ["${var.affinity}"]
}

resource "openstack_compute_instance_v2" "instance" {
  name                = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-instance-${var.deployment_name}-${var.deployment_color}-${var.role_name}-${format("%02d", count.index + 1)}"
  count               = "${var.count}"
  image_id            = "${data.openstack_images_image_v2.base_image.id}"
  flavor_name         = "${var.flavor_name}"
  key_pair            = "${var.key_pair}"
  stop_before_destroy = true
  network             = ["${var.networks}"]
  security_groups     = "${var.security_groups}"
  metadata            = "${local.metadata}"
  user_data           = "${data.template_file.user_data.rendered}"
# user_data           = "${templatefile("${path.module}/user_data.sh.tpl", merge(local.metadata, map("count", format("%02d", count.index + 1))))}"

  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.servergroup.id}"
  }
}
