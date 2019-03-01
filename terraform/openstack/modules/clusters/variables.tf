variable "env" {}
variable "network_name" {}
variable "key_pair" {}
variable "security_groups" {
  type = "list"
}

variable "role" {
  default = "vanilla"
}

variable "count" {
  default = 1
}

variable "image_name" {
  default = "hgi-base-bionic-latest"
}

variable "flavor_name" {
  default = "o1.small"
}

variable "affinity" {
  default = "soft-anti-affinity"
}

variable "subnetpool_name" {
  default = "public"
}
