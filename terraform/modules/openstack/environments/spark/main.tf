# Manages network, subnet, and router
module "spark_network" {
  source                = "../../networks/simple"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  external_network_name = "${var.external_network_name}"
  network_name          = "main"
  subnet_cidr           = "${var.spark_subnet_cidr}"
  dns_nameservers       = "${var.dns_nameservers}"
}

module "workstations_subnet" {
  source                = "../../networks/extra/subnet/"
  os_release            = "${var.os_release}"
  programme             = "${var.programme}"
  env                   = "${var.env}"
  subnet_name           = "workstations"
  subnet_cidr           = "${var.workstations_subnet_cidr}"
  network_id            = "${module.spark_network.network_id}"
  router_id             = "${module.spark_network.router_id}"
  dns_nameservers       = "${var.dns_nameservers}"
}

module "base_cluster" {
  source          = "../../instances/simple"
  os_release      = "${var.os_release}"
  programme       = "${var.programme}"
  env             = "${var.env}"
  role            = "base"
  count           = "${var.count}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.flavor_name}"
  affinity        = "${var.affinity}"
  network_name    = "${module.spark_network.network_name}"
  key_pair        = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-keypair-mercury"
  security_groups = [
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ping",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-ssh",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-tcp-local",
    "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-secgroup-udp-local"
  ]
}
