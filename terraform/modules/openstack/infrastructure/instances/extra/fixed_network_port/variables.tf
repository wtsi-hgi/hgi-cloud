variable "os_release" {}
variable "programme" {}
variable "env" {}
variable "network_name" {}
variable "subnet_name" {}
variable "count" {}
variable "ip_addesses" {
  type = "list"
}
variable "deployment_name" {}
variable "deployment_version" {}
variable "deployment_color" {
  default = "blue"
}
variable "role_name" {
  default = "vanilla"
}
variable "security_groups" {
  type = "list"
}
