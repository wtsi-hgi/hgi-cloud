variable "deployment_name" {
  description = "The name of the deployment"
  type        = "string"
  default     = "main"
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

variable "pet_subnet_cidr" {
  description = "The number of Spark masters to deploy"
  type        = "string"
}

variable "pet_master_external_address" {
  description = "The number of Spark masters to deploy"
  type        = "string"
}

variable "pet_master_address" {
  description = "The number of Spark masters to deploy"
  type        = "string"
}

variable "pet_masters_count" {
  description = "The number of Spark masters to deploy"
  type        = "string"
  default     = "1"
}

variable "pet_slaves_count" {
  description = "The number of Spark slaves to deploy"
  type        = "string"
  default     = 1
}

variable "pet_masters_flavor_name" {
  description = "The name of the flavour the Spark masters instances"
  type        = "string"
  default     = "o2.small"
}

variable "pet_slaves_flavor_name" {
  description = "The name of the flavour the Spark slaves instances"
  type        = "string"
  default     = "o2.small"
}

variable "pet_masters_affinity" {
  description = "The type of affinity of the Spark masters instances"
  type        = "string"
  default     = "soft-anti-affinity"
}

variable "pet_slaves_affinity" {
  description = "The type of affinity of the Spark slaves instances"
  type        = "string"
  default     = "soft-anti-affinity"
}

variable "key_pair" {
  description = "The name of the default SSH key pair"
  type        = "string"
  default     = ""
}

variable "vault_password" {}
