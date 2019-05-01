provider "openstack" {
  version = "~> 1.16"
}
provider "template" {
  version = "~> 2.1"
}

# Package-like metadata
locals {
  deployment_version = "0.0.1"
  dependency = {
    pet_master_image_name = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-image-hail-base-0.0.3"
    pet_master_role_version = "pet-1"
    pet_slave_image_name =  "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-image-hail-base-0.0.3"
    pet_slave_role_version = "pet-1"
  }
}

# Actual locals/defaults: you can't create default input values that are made
# of other default input values.
locals {
  key_pair = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-keypair-mercury"
  pet_slaves_network = "pet"
  pet_masters_network = "pet"
  pet_slaves_subnet = "pet"
  pet_masters_subnet = "pet"
}

module "pet_masters" {
  source              = "../../infrastructure/instances/fixed/"
  os_release          = "${var.os_release}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  deployment_name     = "${var.deployment_name}"
  deployment_color    = "${var.deployment_color}"
  deployment_version  = "${local.deployment_version}"
  role_name           = "spark-master"
  role_version        = "${local.dependency["pet_master_role_version"]}"
  image_name          = "${local.dependency["pet_master_image_name"]}"
  key_pair            = "${ var.key_pair != "" ? var.key_pair : local.key_pair }"
  security_groups     = [
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-base",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ssh",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-spark-master"
  ]
  count               = 1
  flavor_name         = "${var.pet_masters_flavor_name}"
  affinity            = "${var.pet_masters_affinity}"
  network_name        = "${local.pet_masters_network}"
  subnet_name         = "${local.pet_masters_subnet}"
  ip_addresses        = ["${var.pet_master_address}"]
  vault_password      = "${var.vault_password}"
}

module "pet_slaves" {
  source              = "../../infrastructure/instances/standard/"
  os_release          = "${var.os_release}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  deployment_name     = "${var.deployment_name}"
  deployment_color    = "${var.deployment_color}"
  deployment_version  = "${local.deployment_version}"
  role_name           = "spark-slave"
  role_version        = "${local.dependency["pet_slave_role_version"]}"
  image_name          = "${local.dependency["pet_slave_image_name"]}"
  key_pair            = "${ var.key_pair != "" ? var.key_pair : local.key_pair }"
  security_groups     = [
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-base",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ssh",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-spark-slave"
  ]
  count               = "${var.pet_slaves_count}"
  flavor_name         = "${var.pet_slaves_flavor_name}"
  affinity            = "${var.pet_slaves_affinity}"
  network_name        = "${local.pet_slaves_network}"
  vault_password      = "${var.vault_password}"
  depends_on          = ["${module.pet_masters.instance_ids}" ]
}

# module "spark_masters_external_ip" {
#   source            = "../../infrastructure/instances/extra/external_ip/"
#   instances_count   = "${var.spark_masters_count}"
#   floating_ip_pool  = "public"
#   instance_ids      = "${module.spark_masters.instance_ids}"
# }
# 
# module "spark_slaves_external_ip" {
#   source            = "../../infrastructure/instances/extra/external_ip/"
#   instances_count   = "${var.spark_slaves_count}"
#   floating_ip_pool  = "public"
#   instance_ids      = "${module.spark_slaves.instance_ids}"
# }