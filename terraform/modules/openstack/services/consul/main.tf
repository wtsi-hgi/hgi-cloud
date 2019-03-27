module "consensus_network" {
  source          = "../../infrastructure/networks/isolated/"
  os_release      = "${var.os_release}"
  programme       = "${var.programme}"
  env             = "${var.env}"
  network_name    = "consul-consensus"
  dns_nameservers = "${var.dns_nameservers}"
  subnet_cidr     = "${var.subnet_cidr}"
}

locals {
  consensus_network = [{ name = "${module.consensus_network.network_name}"}]
}

module "consul_cluster" {
  source          = "../../infrastructure/instances/simple/"
  os_release      = "${var.os_release}"
  programme       = "${var.programme}"
  env             = "${var.env}"
  role            = "consul"
  count           = "${var.consul_servers}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.flavor_name}"
  affinity        = "${var.affinity}"
  networks        = "${concat(var.networks, local.consensus_network)}"
  key_pair        = "${var.key_pair}"
  security_groups = "${var.security_groups}"
}
