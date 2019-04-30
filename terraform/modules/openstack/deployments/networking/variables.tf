variable "env" {
  type        = "string"
  description = "The name of environment"
}

variable "programme" {}

variable "os_release" {}

variable "external_network_name" {}
variable "main_subnet_cidr" {}
variable "workstations_subnet_cidr" {}
variable "build_subnet_cidr" {}
variable "management_subnet_cidr" {}
variable "consensus_subnet_cidr" {}
variable "pet_subnet_cidr" {}
variable "pet_master_address" {}
variable "external_dns_nameservers" {
  type = "list"
}
variable "local_dns_nameservers" {
  type = "list"
}
