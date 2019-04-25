variable "os_release" {}
variable "programme" {}
variable "env" {}
variable "external_network_name" {}
variable "spark_subnet_cidr" {}
variable "workstations_subnet_cidr" {}
variable "build_subnet_cidr" {}
variable "management_subnet_cidr" {}
variable "consensus_subnet_cidr" {}
variable "mercury_public_key" {}
variable "dns_nameservers" {
  type = "list"
}
variable "count" {}
variable "image_name" {}
variable "flavor_name" {}
variable "affinity" {}
