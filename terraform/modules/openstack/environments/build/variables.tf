variable "env" {
  type        = "string"
  description = "The name of environment"
}

variable "programme" {}

variable "os_release" {
}

variable "external_network_name" {
  type        = "string"
  description = "The name of the externale network"
}

variable "build_subnet_cidr" {
  type        = "string"
  description = "The CIDR of the main and only subnet"
}

variable "dns_nameservers" {
  type        = "list"
  description = "The list of the DNS servers"
}

variable "depends_on" {
  type = "list",
  default = []
}