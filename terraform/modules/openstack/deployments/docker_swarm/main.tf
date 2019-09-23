terraform {
  backend "s3" {}
}


provider openstack {
  version = "~> 1.16"
}

locals {
  deployment_version    = "0.1.0" 
  deployment_name       = "docker_swarm"
  # other_data            = {

  # }
} 



module "docker_manager" {

  source                = "../../infrastructure/instances/standard/"
  datacentre            = "${var.datacentre}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  deployment_name       = "${local.deployment_name}"
  deployment_color      = "blue"
  deployment_owner      = "${var.deployment_owner}"
  image_name            = "${var.image_name}"

  security_groups       = [
      "${var.datacenter}-${var.programme}-${var.env}-secgroup-base",
      "${var.datacenter}-${var.programme}-${var.env}-secgroup-ssh",
      "${var.datacentre}-${var.programme}-${var.env}-secgroup-docker_swarm-manager"
  ]
  count                 = 1
  flavor_name          = "${var.docker_manager_flavor_name}"
  network_name          = "${var.docker_manager_network_name}"
  # affinity.  default = "soft-anti-affinity"
  # role_name  default vanilla
  # role_version  default = "HEAD"
  # other_data          = "${local.other_data}"  default = {}

}



module "docker_workers" {

  source                = "../../infrastructure/instances/standard/"
  datacentre            = "${var.datacentre}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  deployment_name       = "${local.deployment_name}"
  deployment_color      = "blue"
  deployment_owner      = "${var.deployment_owner}"
  image_name            = "${var.image_name}"

  security_groups       = [
      "${var.datacenter}-${var.programme}-${var.env}-secgroup-base",
      "${var.datacenter}-${var.programme}-${var.env}-secgroup-ssh",
      "${var.datacentre}-${var.programme}-${var.env}-secgroup-docker_swarm-worker"
  ]

  count                 = "${var.docker_workers_count}"
  flavour_name          = "${var.docker_workers_flavor_name}"
  network_name          = "${var.docker_workers_network_name}"
  depends_on            = ["${module.docker_manager.instance_ids}"]
  # affinity
  # role_name
  # role_version
  # other_data          = "${local.other_data}" 

}

# Why do manager and workers have different network names?
# How do we get instance ids?
resource "openstack_compute_floatingip_associate_v2" "public_ip" {

  floating_ip = "${var.docker_manager_external_address}"
  instance_id - "${module.docker_manager.instance_ids[0]}"
  
}













