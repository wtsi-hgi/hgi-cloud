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
    spark_master_image_name = "${var.datacenter}-${var.programme}-image-hail-base-0.0.7"
    spark_master_role_version = "HEAD"
    spark_slave_image_name =  "${var.datacenter}-${var.programme}-image-hail-base-0.0.7"
    spark_slave_role_version = "HEAD"
  }
}

# Actual locals/defaults: you can't create default input values that are made
# of other default input values.
locals {
  key_pair = "${var.datacenter}-${var.programme}-${var.env}-keypair-mercury"
  spark_slaves_network = "main"
  spark_masters_network = "main"
  spark_slaves_subnet = "main"
  spark_masters_subnet = "main"
}

module "spark_masters" {
  source              = "../../infrastructure/instances/standard/"
  datacenter          = "${var.datacenter}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  deployment_name     = "${var.deployment_name}"
  deployment_color    = "${var.deployment_color}"
  deployment_owner    = "${var.deployment_owner}"
  role_name           = "spark-master"
  role_version        = "${local.dependency["spark_master_role_version"]}"
  image_name          = "${local.dependency["spark_master_image_name"]}"
  extra_user_data     = "${map("spark_master_private_address", "", "spark_master_external_address", var.spark_master_external_address)}"
  key_pair            = "${local.key_pair}"
  security_groups     = [
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-base",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-ssh",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-spark-master"
  ]
  count               = 1
  flavor_name         = "${var.spark_masters_flavor_name}"
  affinity            = "${var.spark_masters_affinity}"
  network_name        = "${local.spark_masters_network}"
  vault_password      = "${var.vault_password}"
}

module "spark_slaves" {
  source              = "../../infrastructure/instances/standard/"
  datacenter          = "${var.datacenter}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  deployment_name     = "${var.deployment_name}"
  deployment_color    = "${var.deployment_color}"
  deployment_owner    = "${var.deployment_owner}"
  role_name           = "spark-slave"
  role_version        = "${local.dependency["spark_slave_role_version"]}"
  image_name          = "${local.dependency["spark_slave_image_name"]}"
  extra_user_data     = "${map("spark_master_private_address", module.spark_masters.access_ip_v4s[0], "spark_master_external_address", var.spark_master_external_address)}"
  key_pair            = "${local.key_pair}"
  security_groups     = [
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-base",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-ssh",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-spark-slave"
  ]
  count               = "${var.spark_slaves_count}"
  flavor_name         = "${var.spark_slaves_flavor_name}"
  affinity            = "${var.spark_slaves_affinity}"
  network_name        = "${local.spark_slaves_network}"
  vault_password      = "${var.vault_password}"
  depends_on          = ["${module.spark_masters.instance_ids}" ]
}

resource "openstack_compute_floatingip_associate_v2" "public_ip" {
  floating_ip = "${var.spark_master_external_address}"
  instance_id = "${module.spark_masters.instance_ids[0]}"
}
