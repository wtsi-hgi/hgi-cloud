

variable "datacenter" {}

variable "programme" {}

variable "env" {}

variable "deployment_name" {}

variable "deployment_owner" {}

variable "network_name" {}

variable "listener_port" {

}

variable "protocol" {
  default = "TCP"
}

variable "security_groups" {
  type = "list"
}

variable "instance_access_ip_v4s" {
  type = "list"
}

variable "lb_method" {
  default = "ROUND_ROBIN"
}

variable "count" {
  default = 1
}

variable "member_count" {
  default = 1
}