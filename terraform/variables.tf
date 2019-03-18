variable "tenant_name" {}
variable "region" {}
variable "env" {}
variable "mercury_public_key" {}
variable "external_network_name" {}
variable "subnet_cidr" {}
variable "dns_nameservers" {
  type = "list"
}

variable "role" {
  default = "vanilla"
}

variable "count" {
  default = 1
}

variable "image_name" {
  default = "bionic-server"
}

variable "flavor_name" {
  default = "o1.small"
}

variable "affinity" {
  default = "soft-anti-affinity"
}

variable "os_release" {
  default = "eta"
}
