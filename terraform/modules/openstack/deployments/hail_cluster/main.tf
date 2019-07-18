terraform { backend "s3" {} }
provider "openstack" { version = "~> 1.16" }
provider "template" { version = "~> 2.1" }

# Package-like metadata
locals {
  deployment_version  = "0.3.0"
  deployment_name     = "hail"
  dependency          = { }
  other_data          = {
    password                      = "${var.password}"
    spark_master_external_address = "${var.spark_master_external_address}"
    aws_access_key_id             = "${var.aws_access_key_id}"
    aws_secret_access_key         = "${var.aws_secret_access_key}"
    aws_s3_endpoint               = "${var.aws_s3_endpoint}"
    aws_default_region            = "${var.aws_default_region}"
  }
}

# terraform {
#   backend "swift" {
#     container         = "${var.datacenter}-${var.programme}-${var.env}-terarform-${var.deployment_owner}-${local.deployment_name}-state"
#     archive_container = "${var.datacenter}-${var.programme}-${var.env}-terarform-${var.deployment_owner}-${local.deployment_name}-archive"
#   }
# }

module "hail_master" {
  source              = "../../infrastructure/instances/standard/"
  datacenter          = "${var.datacenter}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  deployment_name     = "${local.deployment_name}"
  deployment_color    = "${var.deployment_color}"
  deployment_owner    = "${var.deployment_owner}"
  role_name           = "hail-master"
  role_version        = "${var.spark_master_role_version}"
  image_name          = "${var.spark_master_image_name}"
  other_data          = "${merge(local.other_data, map("spark_master_private_address", ""))}"
  security_groups     = [
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-base",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-ssh",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-spark-master"
  ]
  count               = 1
  flavor_name         = "${var.spark_master_flavor_name}"
  affinity            = "${var.spark_master_affinity}"
  network_name        = "${var.spark_master_network_name}"
}

resource "openstack_compute_floatingip_associate_v2" "public_ip" {
  floating_ip = "${var.spark_master_external_address}"
  instance_id = "${module.hail_master.instance_ids[0]}"
}

module "hail_volume" {
  source              = "../../infrastructure/instances/extra/persistent_volume"
  volume_ids          = ["${var.hail_volume}"]
  instance_ids        = "${module.hail_master.instance_ids}"
}

module "hail_slaves" {
  source              = "../../infrastructure/instances/standard/"
  datacenter          = "${var.datacenter}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  deployment_name     = "${local.deployment_name}"
  deployment_color    = "${var.deployment_color}"
  deployment_owner    = "${var.deployment_owner}"
  role_name           = "hail-slave"
  role_version        = "${var.spark_slaves_role_version}"
  image_name          = "${var.spark_slaves_image_name}"
  other_data          = "${merge(local.other_data, map("spark_master_private_address", module.hail_master.access_ip_v4s[0]))}"
  security_groups     = [
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-base",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-ssh",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-spark-slave"
  ]
  count               = "${var.spark_slaves_count}"
  flavor_name         = "${var.spark_slaves_flavor_name}"
  affinity            = "${var.spark_slaves_affinity}"
  network_name        = "${var.spark_slaves_network_name}"
  depends_on          = ["${module.hail_master.instance_ids}" ]
}
