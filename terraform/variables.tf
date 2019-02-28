variable "tenant_name" {}
variable "region" {}
variable "env" {}
variable "jr17_public_key" {}
variable "mercury_public_key" {}
variable "external_network_name" {}
variable "subnet_cidr" {}
variable "dns_nameservers" {
  type = "list"
}
