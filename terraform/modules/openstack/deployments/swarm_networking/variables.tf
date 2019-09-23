variable "env" {
  type        = "string"
  description = "The name of environment"
}

variable "programme" {}

variable "datacenter" {}

# variable "deployment_owner" {}

variable "external_network_name" {}
variable "main_subnet_cidr" {}
variable "management_subnet_cidr" {}
variable "external_dns_nameservers" {
  type = "list"
}
variable "local_dns_nameservers" {
  type = "list"
}
