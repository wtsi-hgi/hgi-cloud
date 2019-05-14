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
    spark_master_image_name = "${var.datacenter}-${var.programme}-${var.env}-image-hail-base-0.0.2"
    spark_master_role_version = "HEAD"
    spark_slave_image_name =  "${var.datacenter}-${var.programme}-${var.env}-image-hail-base-0.0.2"
    spark_slave_role_version = "HEAD"
  }
}

# Actual locals/defaults: you can't create default input values that are made
# of other default input values.
locals {
  key_pair = "${var.datacenter}-${var.programme}-${var.env}-keypair-mercury"
  spark_slaves_network = "${var.datacenter}-${var.programme}-${var.env}-network-main"
  spark_masters_network = "${var.datacenter}-${var.programme}-${var.env}-network-main"
}

module "spark_masters" {
  source              = "../../infrastructure/instances/simple/"
  datacenter          = "${var.datacenter}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  deployment_name     = "${var.deployment_name}"
  deployment_color    = "${var.deployment_color}"
  deployment_owner    = "${var.deployment_owner}"
  role_name           = "spark-master"
  role_version        = "${local.dependency["spark_master_role_version"]}"
  image_name          = "${local.dependency["spark_master_image_name"]}"
  key_pair            = "${ var.key_pair != "" ? var.key_pair : local.key_pair }"
  security_groups     = [
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-ping",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-ssh",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-spark-master",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-tcp-local",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-udp-local"
  ]
  count               = "${var.spark_masters_count}"
  flavor_name         = "${var.spark_masters_flavor_name}"
  affinity            = "${var.spark_masters_affinity}"
  networks            = [{ name = "${ var.spark_masters_network != "" ? var.spark_masters_network : local.spark_masters_network }" }]
}

module "spark_slaves" {
  source              = "../../infrastructure/instances/simple/"
  datacenter          = "${var.datacenter}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  deployment_name     = "${var.deployment_name}"
  deployment_color    = "${var.deployment_color}"
  deployment_owner    = "${var.deployment_owner}"
  role_name           = "spark-slave"
  role_version        = "${local.dependency["spark_slave_role_version"]}"
  image_name          = "${local.dependency["spark_slave_image_name"]}"
  key_pair            = "${ var.key_pair != "" ? var.key_pair : local.key_pair }"
  security_groups     = [
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-ping",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-ssh",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-spark-slave",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-tcp-local",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-udp-local"
  ]
  count               = "${var.spark_slaves_count}"
  flavor_name         = "${var.spark_slaves_flavor_name}"
  affinity            = "${var.spark_slaves_affinity}"
  networks            = [{ name = "${ var.spark_slaves_network != "" ? var.spark_slaves_network : local.spark_slaves_network }" }]
  depends_on          = [ "module.spark_masters.instance_id" ]
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
