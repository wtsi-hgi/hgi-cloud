variable "env" {
  type        = "string"
  description = "The name of environment"
}

variable "programme" {}

variable "datacenter" {}

variable "deployment_owner" {
  default = ""
}

variable "external_network_name" {
  type        = "string"
  description = "The name of the external network"
}

variable "network_name" {}

variable "subnet_cidr" {
  type        = "string"
  description = "The CIDR of the main and only subnet"
}

variable "subnet_pool_start" {
  description = "The IP pool index to start from"
  default     = "2"
}

variable "subnet_pool_end" {
  description = "The IP pool index to end with"
  default     = "-2"
}

variable "dns_nameservers" {
  type        = "list"
  description = "The list of the DNS servers"
}
