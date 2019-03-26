# Manages network, subnet, and router
module "spark_network" {
  source                = "../../infrastructure/networks/routed"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  external_network_name = "${var.external_network_name}"
  network_name          = "main"
  subnet_cidr           = "${var.spark_subnet_cidr}"
  dns_nameservers       = "${var.dns_nameservers}"
}

module "workstations_network" {
  source                = "../../infrastructure/networks/extra/network/"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  subnet_cidr           = "${var.workstations_subnet_cidr}"
  network_name          = "workstations"
  router_id             = "${module.spark_network.router_id}"
  dns_nameservers       = "${var.dns_nameservers}"
}

module "management_network" {
  source                = "../../infrastructure/networks/extra/network/"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  subnet_cidr           = "${var.management_subnet_cidr}"
  network_name          = "management"
  router_id             = "${module.spark_network.router_id}"
  dns_nameservers       = "${var.dns_nameservers}"
}

module "consensus_network" {
  source                = "../../infrastructure/networks/isolated/"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  subnet_cidr           = "${var.consensus_subnet_cidr}"
  network_name          = "consensus"
  dns_nameservers       = "${var.dns_nameservers}"
}

module "spark_cluster" {
  source          = "../../services/spark-cluster"
  os_release      = "${var.os_release}"
  programme       = "${var.programme}"
  env             = "${var.env}"
  spark_masters   = "1"
  spark_slaves    = "3"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.flavor_name}"
  affinity        = "${var.affinity}"
  networks        = [
    {
      name = "${module.spark_network.network_name}"
    }
  ]
  key_pair        = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-keypair-mercury"
  security_groups = [
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ping",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ssh",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-tcp-local",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-udp-local"
  ]
}

module "workstations" {
  source          = "../../services/ssh-gateway"
  os_release      = "${var.os_release}"
  programme       = "${var.programme}"
  env             = "${var.env}"
  count           = "${var.count}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.flavor_name}"
  affinity        = "${var.affinity}"
  networks        = [ { name = "${module.workstations_network.network_name}" } ]
  key_pair        = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-keypair-mercury"
  security_groups = [
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ping",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ssh",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-tcp-local",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-udp-local"
  ]
}

module "consul" {
  source          = "../../services/consul"
  os_release      = "${var.os_release}"
  programme       = "${var.programme}"
  env             = "${var.env}"
  count           = "${var.count}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.flavor_name}"
  affinity        = "${var.affinity}"
  subnet_cidr     = "${var.consensus_subnet_cidr}"
  dns_nameservers = "${var.dns_nameservers}"
  networks        = [ { name = "${module.workstations_network.network_name}" } ]
  key_pair        = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-keypair-mercury"
  security_groups = [
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ping",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ssh",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-tcp-local",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-udp-local"
  ]
}
