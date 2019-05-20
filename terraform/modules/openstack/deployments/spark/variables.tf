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

variable "deployment_owner" {
  description = "The owner of the deployment"
  type        = "string"
  default     = "mercury"
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

variable "spark_master_external_address" {
  description = "The number of Spark masters to deploy"
  type        = "string"
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

variable "spark_masters_image_name" {}
variable "spark_masters_role_name" {
  default     = "spark-master"
}
variable "spark_masters_role_version" {
  default     = "HEAD"
}

variable "spark_slaves_image_name" {}
variable "spark_slaves_role_name" {
  default     = "spark-slave"
}
variable "spark_slaves_role_version" {
  default     = "HEAD"
}

variable "spark_masters_network_name" {
  default     = "main"
}

variable "spark_slaves_network_name" {
  default     = "main"
}

variable "vault_password" {}
