variable "os_release" {}
variable "programme" {}
variable "env" {}
variable "port_name" {}
variable "network_id" {}
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
