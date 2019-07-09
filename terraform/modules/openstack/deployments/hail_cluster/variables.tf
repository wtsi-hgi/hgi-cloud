variable "password" {
  description = "The password to unlock the private volume and Jupyter's notebook."
}

variable "spark_slaves_count" {
  description = "The number of Spark slaves to deploy"
  default     = 2
}

variable "spark_slaves_flavor_name" {
  description = "The name of the flavour of the Spark slaves instances"
  default     = "m1.medium"
}

variable "spark_masters_flavor_name" {
  description = "The name of the flavour of the Spark masters instance"
  default     = "m1.medium"
}

# This is temporarily necessary. This value is manually assigned to the user.
variable "spark_master_external_address" {
  description = "The public network IP address for the Spark master"
}

# The folowing are usually auto-configured or admin values. Users should not need to override any of them.
variable "datacenter" {
  description = "The name of the datacenter for this deployment"
  default     = "eta"
}

variable "programme" {
  description = "The name of the programme that owns this deployment"
  default     = "hgi"
}

variable "env" {
  description = "The name of the environment for this deployment"
  default     = "dev"
}

variable "deployment_owner" {
  description = "The userid of the owner of the deployment"
}

variable "deployment_color" {
  description = "The color of the deployment"
  default     = "blue"
}

variable "spark_masters_affinity" {
  description = "The type of affinity of the Spark masters instances"
  default     = "soft-anti-affinity"
}

variable "spark_slaves_affinity" {
  description = "The type of affinity of the Spark slaves instances"
  default     = "soft-anti-affinity"
}

variable "spark_masters_image_name" {
  description = "The name of the image to deploy on the Spark master"
}

variable "spark_masters_role_name" {
  description = "The name of the role that the Spark master has to assume in the cluster"
  default     = "hail-master"
}

# Any value that can be used in a "git checkout" command
variable "spark_masters_role_version" {
  description = "The version of the role that the Spark master has to assume in the cluster"
  default     = "HEAD"
}

variable "spark_slaves_image_name" {
  description = "The name of the image to deploy on the Spark slaves"
}

variable "spark_slaves_role_name" {
  description = "The name of the role that the Spark slaves have to assume in the cluster"
  default     = "hail-slave"
}

# Any value that can be used in a "git checkout" command
variable "spark_slaves_role_version" {
  description = "The version of the role that the Spark slaves have to assume in the cluster"
  default     = "HEAD"
}

variable "spark_masters_network_name" {
  description = "The name-tag of the network where the spark master has to be deployed in"
  default     = "main"
}

variable "spark_slaves_network_name" {
  description = "The name-tag of the network where the spark slaves have to be deployed in"
  default     = "main"
}

variable "hail_volume" {
}

variable "aws_access_key_id" {
}

variable "aws_secret_access_key" {
}

variable "aws_s3_endpoint" {
}

variable "aws_default_region" {
}
