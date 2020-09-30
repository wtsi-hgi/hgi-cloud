variable "datacenter" {

  default = "theta"

}

variable "programme" {
  default = "hti"
}

variable "env" {
  default = "dev"
}

variable "deployment_owner" {

}


variable "docker_manager_image_name" {
  default = "bionic-WTSI-docker_49930_38ab07e9"
}


variable "docker_worker_image_name" {
  default = "bionic-WTSI-docker_49930_38ab07e9"
}


variable "docker_manager_flavor_name" {
  default  = "m2.medium"
}


variable "docker_workers_flavor_name" {
   default     = "m2.medium"
}

variable "docker_manager_network_name" {
  default = "docker-main"

}

variable "docker_workers_network_name" {
  default = "docker-main"

}


variable "docker_manager_external_address" {

}


variable "docker_workers_count" {

  default = 1

}


variable "docker_manager_role_version" {

}


variable "docker_workers_role_version" {

}









