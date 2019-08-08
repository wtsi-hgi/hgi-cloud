variable "datacenter" {}
variable "programme" {}
variable "env" {}
variable "network_name" {}
variable "subnet_name" {}
variable "count" {
  default = 1
}
variable "ip_addresses" {
  type = "list"
}
variable "deployment_owner" {}
variable "deployment_name" {}
variable "deployment_color" {
  default = "blue"
}
variable "role_name" {
  default = "vanilla"
}
variable "security_groups" {
  type = "list"
}
