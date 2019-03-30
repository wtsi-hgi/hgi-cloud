locals {
  deployment_version = "0.0.0"
  dependency = {
    ssh_gateway_image_name = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-image-base-0.0.0"
    ssh_gateway_role_version = "0.0.0"
  }
}

module "ssh_gateway" {
  source              = "../../infrastructure/instances/simple/"
  env                 = "${var.env}"
  programme           = "${var.programme}"
  os_release          = "${var.os_release}"
  deployment_name     = "${var.deployment_name}"
  deployment_color    = "${var.deployment_color}"
  deployment_version  = "${local.deployment_version}"
  role_name           = "ssh-gateway"
  role_version        = "${local.dependency["ssh_gateway_role_version"]}"
  image_name          = "${local.dependency["ssh_gateway_image_name"]}"
  key_pair            = "${var.key_pair}"
  security_groups     = [
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ping",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ssh",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-tcp-local",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-udp-local"
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

# resource "infoblox_record" "ssh-gateway" {
#   value  = "${openstack_compute_floatingip_associate_v2.ssh-gateway.floating_ip}"
#   name   = "ssh"
#   domain = "${var.domain}"
#   type   = "A"
#   ttl    = 600
#   view   = "internal"
# }
