variable "env" {}
variable "programme" {}
variable "datacenter" {}
variable "networks" {
  type = "list"
}
variable "count" {
  default = 3
}
variable "key_pair" {}
variable "security_groups" {
  type = "list"
}

variable "consul_servers" {
  default = 3
}

variable "image_name" {
  default = "bionic-server"
}

variable "flavor_name" {
  default = "o2.small"
}

variable "affinity" {
  default = "soft-anti-affinity"
}

variable "subnetpool_name" {
  default = "public"
}

variable "dns_nameservers" {
  type = "list"
}

variable "subnet_cidr" {}
