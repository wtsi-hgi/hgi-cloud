variable "datacenter" {}
variable "programme" {}
variable "env" {}
variable "deployment_owner" {}
variable "hail_volume_size" {
  default = 32
}
variable "depends_on" {
  default = ""
}
