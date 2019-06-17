terraform { backend "s3" {} }
provider "openstack" { version = "~> 1.16" }
provider "template" { version = "~> 2.1" }

# Package-like metadata
locals {
  deployment_version = "0.1.0"
  dependency = { }
}

# terraform {
#   backend "swift" {
#     container         = "${var.datacenter}-${var.programme}-${var.env}-terarform-${var.deployment_owner}-${var.deployment_name}-state"
#     archive_container = "${var.datacenter}-${var.programme}-${var.env}-terarform-${var.deployment_owner}-${var.deployment_name}-archive"
#   }
# }

module "spark_masters" {
  source              = "../../infrastructure/instances/standard/"
  datacenter          = "${var.datacenter}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  deployment_name     = "${var.deployment_name}"
  deployment_color    = "${var.deployment_color}"
  deployment_owner    = "${var.deployment_owner}"
  role_name           = "${var.spark_masters_role_name}"
  role_version        = "${var.spark_masters_role_version}"
  image_name          = "${var.spark_masters_image_name}"
  other_data          = "${map("password", var.password, "spark_master_private_address", "", "spark_master_external_address", var.spark_master_external_address)}"
  security_groups     = [
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-base",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-ssh",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-spark-master"
  ]
  count               = 1
  flavor_name         = "${var.spark_masters_flavor_name}"
  affinity            = "${var.spark_masters_affinity}"
  network_name        = "${var.spark_masters_network_name}"
}

resource "openstack_compute_floatingip_associate_v2" "public_ip" {
  floating_ip = "${var.spark_master_external_address}"
  instance_id = "${module.spark_masters.instance_ids[0]}"
}

module "jupyter_data" {
  source              = "../../infrastructure/instances/extra/persistent_volume"
  volume_ids          = ["${var.jupyter_data_volume}"]
  instance_ids        = "${module.spark_masters.instance_ids}"
}

resource "null_resource" "wait" {
  provisioner "local-exec" {
    command   = "sleep 2"
  }
  triggers = { jupyter_data_attached = "${join("", module.jupyter_data.attached)}" }
}

module "tmp_dir" {
  source              = "../../infrastructure/instances/extra/volatile_volume"
  datacenter          = "${var.datacenter}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  deployment_name     = "${var.deployment_name}"
  deployment_owner    = "${var.deployment_owner}"
  role_name           = "${var.spark_slaves_role_name}"
  volume_name         = "tmp_dir"
  size                = "${var.tmp_dir_size}"
  instance_ids        = "${module.spark_masters.instance_ids}"
  count               = 1
  depends_on          = ["${null_resource.wait.id}"]
}

module "spark_slaves" {
  source              = "../../infrastructure/instances/standard/"
  datacenter          = "${var.datacenter}"
  programme           = "${var.programme}"
  env                 = "${var.env}"
  deployment_name     = "${var.deployment_name}"
  deployment_color    = "${var.deployment_color}"
  deployment_owner    = "${var.deployment_owner}"
  role_name           = "${var.spark_slaves_role_name}"
  role_version        = "${var.spark_slaves_role_version}"
  image_name          = "${var.spark_slaves_image_name}"
  other_data          = "${map("password", var.password, "spark_master_private_address", module.spark_masters.access_ip_v4s[0], "spark_master_external_address", var.spark_master_external_address)}"
  security_groups     = [
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-base",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-ssh",
    "${var.datacenter}-${var.programme}-${var.env}-secgroup-spark-slave"
  ]
  count               = "${var.spark_slaves_count}"
  flavor_name         = "${var.spark_slaves_flavor_name}"
  affinity            = "${var.spark_slaves_affinity}"
  network_name        = "${var.spark_slaves_network_name}"
  depends_on          = ["${module.spark_masters.instance_ids}" ]
}
