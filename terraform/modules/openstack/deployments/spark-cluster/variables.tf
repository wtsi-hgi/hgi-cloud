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
}
variable "programme" {
  description = "The name of the programme that owns this deployment"
  type        = "string"
}
variable "os_release" {
  description = "The name of the Openstack's release"
  type        = "string"
}

variable "key_pair" {
  description = "The name of the default SSH key pair"
  type        = "string"
}

variable "spark_masters_networks" {
  description = "A list of details for each network the Spark masters have to attach to"
  type        = "list"
}
variable "spark_slaves_networks" {
  description = "A list of details for each network the Spark masters have to attach to"
  type        = "list"
}

variable "spark_masters_count" {
  description = "The number of Spark masters to deploy"
  type        = "string"
  default     = "1"
}
variable "spark_slaves_count" {
  description = "The number of Spark slaves to deploy"
  type        = "string"
  default     = 1
}

variable "spark_masters_flavor_name" {
  description = "The name of the flavour the Spark masters instances"
  type        = "string"
  default     = "o2.small"
}

variable "spark_slaves_flavor_name" {
  description = "The name of the flavour the Spark slaves instances"
  type        = "string"
  default     = "o2.small"
}

variable "spark_masters_affinity" {
  description = "The type of affinity of the Spark masters instances"
  type        = "string"
  default     = "soft-anti-affinity"
}

variable "spark_slaves_affinity" {
  description = "The type of affinity of the Spark slaves instances"
  type        = "string"
  default     = "soft-anti-affinity"
}
