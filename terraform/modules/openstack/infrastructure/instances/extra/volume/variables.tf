variable "datacenter" {}
variable "programme" {}
variable "env" {}
variable "volume_name" {}
variable "deployment_name" {}
variable "deployment_owner" {}
variable "role_name" {}
variable "size" {}
variable "instance_ids" {
  type = "list"
}
variable "depends_on" {
  default = ""
}
variable "count" {
  default = 1
}
