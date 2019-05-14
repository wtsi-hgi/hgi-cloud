provider "openstack" {
  version = "~> 1.16"
}
provider "template" {
  version = "~> 2.1"
}

locals {
  deployment_version = "0.0.0"
  dependency = { }
}

module "consensus_network" {
  source          = "../../infrastructure/networks/isolated/"
  datacenter      = "${var.datacenter}"
  programme       = "${var.programme}"
  env             = "${var.env}"
  network_name    = "consul-consensus"
  dns_nameservers = "${var.dns_nameservers}"
  subnet_cidr     = "${var.subnet_cidr}"
}

module "consul_cluster" {
  source          = "../../infrastructure/instances/simple/"
  datacenter      = "${var.datacenter}"
  programme       = "${var.programme}"
  env             = "${var.env}"
  role            = "consul"
  count           = "${var.consul_servers}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.flavor_name}"
  affinity        = "${var.affinity}"
  networks        = "${concat(var.networks, list(map("name", module.consensus_network.network_name)))}"
  key_pair        = "${var.key_pair}"
  security_groups = "${var.security_groups}"
}
