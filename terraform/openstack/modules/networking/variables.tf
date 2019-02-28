variable "env" {
  type        = "string"
  description = "The name of environment"
}

variable "external_network_id" {
  type        = "string"
  description = "The ID of the externale network"
}

variable "subnet" {
  type        = "string"
  description = "The CIDR of the main and only subnet"
}

variable "dns_nameservers" {
  type        = "list"
  description = "The list of the DNS servers"
}

variable "host_routes" {
  type        = "list"
  description = "The list of default routes for each hosts"
  default     = []
}

variable "gateway_ip" {
  type        = "string"
  description = "The IP address of the gateway"
  default     = ""
}
