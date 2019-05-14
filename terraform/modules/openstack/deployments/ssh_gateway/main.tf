provider "openstack" {
  version = "~> 1.16"
}
provider "template" {
  version = "~> 2.1"
}

locals {
  deployment_version = "0.0.0"
  dependency = {
    ssh_gateway_image_name = "${var.datacenter}-${var.programme}-${var.env}-image-base-0.0.0"
    ssh_gateway_role_version = "0.0.0"
  }
}

module "ssh_gateway" {
  source              = "../../infrastructure/instances/simple/"
  env                 = "${var.env}"
  programme           = "${var.programme}"
  datacenter          = "${var.datacenter}"
  deployment_name     = "${var.deployment_name}"
  deployment_color    = "${var.deployment_color}"
  deployment_owner    = "${local.deployment_owner}"
  role_name           = "ssh-gateway"
  role_version        = "${local.dependency["ssh_gateway_role_version"]}"
  image_name          = "${local.dependency["ssh_gateway_image_name"]}"
  key_pair            = "${var.key_pair}"
  security_groups     = [
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-ping",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-ssh",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-tcp-local",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-udp-local"
  ]
  count               = "${var.count}"
  flavor_name         = "${var.flavor_name}"
  affinity            = "${var.affinity}"
  networks            = "${var.networks}"
}

module "external_ip" {
  source            = "../../infrastructure/instances/extra/external_ip/"
  count             = "${var.count}"
  floating_ip_pool  = "public"
  instance_id       = "${module.ssh_gateway.instance_id}"
}
