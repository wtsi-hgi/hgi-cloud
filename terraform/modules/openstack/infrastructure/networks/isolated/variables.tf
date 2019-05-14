variable "env" {
  type        = "string"
  description = "The name of environment"
}

variable "programme" {}

variable "datacenter" {}

variable "deployment_owner" {
  default = ""
}

variable "network_name" {}

variable "subnet_cidr" {
  type        = "string"
  description = "The CIDR of the main and only subnet"
}

variable "dns_nameservers" {
  type        = "list"
  description = "The list of the DNS servers"
}
