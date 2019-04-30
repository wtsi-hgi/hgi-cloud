variable "os_release" {}
variable "programme" {}
variable "env" {}
variable "deployment_name" {}
variable "deployment_version" {}
variable "deployment_color" {
  default = "blue"
}
variable "role_name" {
  default = "vanilla"
}
variable "role_version" {
  default = "HEAD"
}

variable "count" {
  default = 1
}
variable "network_name" {}
variable "key_pair" {}

variable "security_groups" {
  type = "list"
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
variable "depends_on" {
  type = "list"
  default = []
}
variable "vault_password" {}
variable "volume_size" {
  default = 64
}
