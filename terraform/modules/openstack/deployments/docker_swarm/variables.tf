variable "datacenter" {

  default = "eta"

}

variable "programme" {
  default = "hti"
}

variable "env" {
  default = "dev"
}

variable "deployment_owner" {

}


variable "image_name" {
  default = "bionic-WTSI-docker_b5612"
}

variable "docker_manager_flavor_name" {
  default  = "m1.medium"
}


variable "docker_workers_flavor_name" {
   default     = "m1.medium"
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

  default = 2

}


variable "docker_manager_role_version" {

}


variable "docker_workers_role_version" {

}









