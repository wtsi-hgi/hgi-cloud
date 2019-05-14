variable "datacenter" {}
variable "programme" {}
variable "env" {}
variable "network_name" {}
variable "deployment_name" {}
variable "role_name" {
  default = "vanilla"
}
variable "security_groups" {
  type = "list"
}
variable "count" {
  default = 1
}
