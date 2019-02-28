variable "region" {
  type = "string"
}

variable "jr17_public_key" {}
variable "mercury_public_key" {}

variable "env" {
  type        = "string"
  description = "The name of environment"
}

variable "external_network_name" {
  type        = "string"
  description = "The name of the externale network"
}

variable "subnet_cidr" {
  type        = "string"
  description = "The CIDR of the main and only subnet"
}

variable "dns_nameservers" {
  type        = "list"
  description = "The list of the DNS servers"
}
