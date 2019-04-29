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
  count = "${var.count}"
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
    count               = "${count.index + 1}"
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

module "network_port" {
  source          = "../extra/fixed_ip_port/"
  os_release      = "${var.os_release}"
  programme       = "${var.programme}"
  env             = "${var.env}"
  port_name       = "${var.network_name}"
  network_id      = "${var.network_id}"
  subnet_id       = "${var.subnet_id}"
  ip_addresses    = "${var.ip_addresses}"
  deployment_name = "${var.deployment_name}"
  role_name       = "${var.role_name}"
  security_groups = "${var.security_groups}"
  count           = "${var.count}"
}

resource "openstack_compute_instance_v2" "instance" {
  name                = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-instance-${var.deployment_name}-${var.deployment_color}-${var.role_name}-${format("%02d", count.index + 1)}"
  count               = "${var.count}"
  flavor_name         = "${var.flavor_name}"
  key_pair            = "${var.key_pair}"
  stop_before_destroy = true
  security_groups     = "${var.security_groups}"
  metadata            = "${local.metadata}"
  user_data           = "${data.template_file.user_data.rendered}"
# user_data           = "${templatefile("${path.module}/user_data.sh.tpl", merge(local.metadata, map("count", format("%02d", count.index + 1))))}"

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
