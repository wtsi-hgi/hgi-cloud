variable "os_release" {}

variable "programme" {}

variable "env" {
  type        = "string"
  description = "The name of environment"
}

variable "subnet_name" {
  type        = "string"
  description = "The name of the subnet"
}

variable "network_id" {}

variable "router_id" {}

variable "subnet_cidr" {
  type        = "string"
  description = "The CIDR of the main and only subnet"
}

variable "dns_nameservers" {
  type        = "list"
  description = "The list of the DNS servers"
}
