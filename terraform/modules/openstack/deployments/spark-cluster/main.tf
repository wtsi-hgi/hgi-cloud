provider "openstack" {
  version = "~> 1.16"
}
provider "template" {
  version = "~> 2.1"
}

locals {
  deployment_version = "0.0.0"
  dependency = {
    spark_master_image_name = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-image-base-0.0.0"
    spark_master_role_version = "0.0.0"
    spark_slave_image_name =  "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-image-base-0.0.0"
    spark_slave_role_version = "0.0.0"
  }
}

module "spark_master" {
  source              = "../../infrastructure/instances/simple/"
  os_release          = "${var.os_release}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  deployment_name     = "${var.deployment_name}"
  deployment_color    = "${var.deployment_color}"
  deployment_version  = "${local.deployment_version}"
  role_name           = "spark-master"
  role_version        = "${local.dependency["spark_master_role_version"]}"
  image_name          = "${local.dependency["spark_master_image_name"]}"
  key_pair            = "${var.key_pair}"
  security_groups     = [
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ping",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ssh",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-tcp-local",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-udp-local"
  ]
  count               = "${var.spark_masters_count}"
  flavor_name         = "${var.spark_masters_flavor_name}"
  affinity            = "${var.spark_masters_affinity}"
  networks            = "${var.spark_masters_networks}"
}

module "spark_slaves" {
  source              = "../../infrastructure/instances/simple/"
  os_release          = "${var.os_release}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  deployment_name     = "${var.deployment_name}"
  deployment_color    = "${var.deployment_color}"
  deployment_version  = "${local.deployment_version}"
  role_name           = "spark-slave"
  role_version        = "${local.dependency["spark_slave_role_version"]}"
  image_name          = "${local.dependency["spark_slave_image_name"]}"
  key_pair            = "${var.key_pair}"
  security_groups     = [
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ping",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ssh",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-tcp-local",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-udp-local"
  ]
  count               = "${var.spark_slaves_count}"
  flavor_name         = "${var.spark_slaves_flavor_name}"
  affinity            = "${var.spark_slaves_affinity}"
  networks            = "${var.spark_slaves_networks}"
  depends_on          = [ "module.spark_master.instance_id" ]
}
