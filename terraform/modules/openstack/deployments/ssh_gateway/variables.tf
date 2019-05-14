variable "deployment_name" {
  description = "The name of the deployment"
  type        = "string"
  default     = "primary"
}
variable "deployment_color" {
  description = "The color of the deployment"
  type        = "string"
  default     = "blue"
}
variable "env" {
  description = "The name of the environment for this deployment"
  type        = "string"
  default     = "dev"
}
variable "programme" {
  description = "The name of the programme that owns this deployment"
  type        = "string"
  default     = "hgi"
}
variable "datacenter" {
  description = "The name of the Openstack's release"
  type        = "string"
  default     = "eta"
}

variable "count" {
  description = "The number of SSH Gateways to deploy"
  type        = "string"
  default     = "1"
}

variable "flavor_name" {
  description = "The name of the flavour the SSH Gateways instances"
  type        = "string"
  default     = "o2.small"
}

variable "affinity" {
  description = "The type of affinity of the SSH Gateways instances"
  type        = "string"
  default     = "soft-anti-affinity"
}

variable "key_pair" {
  description = "The name of the default SSH key pair"
  type        = "string"
}

variable "networks" {
  description = "A list of details for each network the SSH Gateways have to attach to"
  type        = "list"
}
