variable "datacentre" {

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

}

variable "docker_manager_flavor_name" {
    default     = "m1.medium"
}


variable "docker_workers_flavor_name {

   default     = "m1.medium"

}

variable "docker_manager_network_name" {
  default = "docker-main"

}

variable "docker_workers_network_name" {
  default = "docker-main"

}


variable "docker_maanger_external_address" {

}


variable "docker_workers_count" {

  default = 2

}








