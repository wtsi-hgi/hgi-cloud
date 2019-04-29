variable "os_release" {}
variable "programme" {}
variable "env" {}
variable "port_name" {}
variable "network_id" {}
variable "subnet_id" {}
variable "count" {
  default = 1
}
variable "ip_addresses" {
  type = "list"
}
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
