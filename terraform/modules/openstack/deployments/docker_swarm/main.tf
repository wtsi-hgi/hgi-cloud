terraform {
  backend "s3" {}
}


provider openstack {
  version = "~> 1.16"
}

# Other data is communicated to ansible after merging with some outputs of terraform (e.g. smark master private ip). 

#  How? First, the "instance_id"  output of the "spark_master module" is assigned to "other_data" argument, This argument is passed to the module "spark_slave" when its time to create slaves alongwith other metadata (datacentre, program etc.) 

#  The "spark_slave" module then uses the "other_data" passed to it to its "user_data" module (alongwith the other metadata!) in an argument "template_vars"

#  The "user_data" module takes these template_vars (which has the original private address of master), attaches a count to it, and then passses it to the template file "user_data.sh.tpl"

# The template files generates a string which does the following:
# clones the ansible git repo
# writes the other_data to a file in the git rep
# call ansible with the var file as an extra command line argument. 


# This string is passed to the "user_data" attribute provided by openstack "openstack_compute_instance_v2", which then executes it at as  shell script at boot time. 

# As part of the ansible execution,  the "common" role at ansible ensures that etc/hosts is modifed to register the spark_master_private_ip as spark-master, which can be referred to by any future provisioning. 


locals {
  deployment_version    = "0.1.0" 
  deployment_name       = "docker_swarm"
  other_data            = {
    docker_manager_external_address = "${var.docker_manager_external_address}"

  }
} 



module "docker_manager" {

  source                = "../../infrastructure/instances/standard/"
  datacenter            = "${var.datacenter}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  deployment_name       = "${local.deployment_name}"
  deployment_color      = "blue"
  deployment_owner      = "${var.deployment_owner}"
  image_name            = "${var.docker_manager_image_name}"

  security_groups       = [
      "${var.datacenter}-${var.programme}-${var.env}-secgroup-base",
      "${var.datacenter}-${var.programme}-${var.env}-secgroup-ssh",
      "${var.datacenter}-${var.programme}-${var.env}-secgroup-docker_swarm-manager",
      "${var.datacenter}-${var.programme}-${var.env}-secgroup-docker_swarm-worker"
  ]
  count                = 1
  flavor_name          = "${var.docker_manager_flavor_name}"
  network_name         = "${var.docker_manager_network_name}"
  # affinity.  default = "soft-anti-affinity"
  role_name            = "docker-swarm-manager"
  role_version         = "${var.docker_manager_role_version}"
  other_data           = "${merge(local.other_data, map("docker_manager_private_address", ""))}"

}



module "docker_workers" {

  source                = "../../infrastructure/instances/standard/"
  datacenter            = "${var.datacenter}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  deployment_name       = "${local.deployment_name}"
  deployment_color      = "blue"
  deployment_owner      = "${var.deployment_owner}"
  image_name            = "${var.docker_worker_image_name}"

  security_groups       = [
      "${var.datacenter}-${var.programme}-${var.env}-secgroup-base",
      "${var.datacenter}-${var.programme}-${var.env}-secgroup-ssh",
      "${var.datacenter}-${var.programme}-${var.env}-secgroup-docker_swarm-worker"
  ]

  count                 = "${var.docker_workers_count}"
  flavor_name           = "${var.docker_workers_flavor_name}"
  network_name          = "${var.docker_workers_network_name}"
  depends_on            = ["${module.docker_manager.instance_ids}"]
  # affinity
  role_name             = "docker-swarm-worker"
  role_version          = "${var.docker_workers_role_version}"
  other_data            = "${merge(local.other_data, map("docker_manager_private_address", module.docker_manager.access_ip_v4s[0]))}"
  # Fix: For supporting multiple docker managers, woudl need to send the entire array and make the accompanying code changes.  

}

# Why do manager and workers have different network names?
# How do we get instance ids?
resource "openstack_compute_floatingip_associate_v2" "public_ip" {

  floating_ip = "${var.docker_manager_external_address}"
  instance_id = "${module.docker_manager.instance_ids[0]}"
  
}


resource "openstack_lb_loadbalancer_v2" "lb_1" {
  vip_subnet_id = "d9415786-5f1a-428b-b35f-2f1523e146d2" "${var.docker_manager_network_name}"

}












