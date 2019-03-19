module "environment" {
  source                = "modules/environment/"
  os_release            = "${var.os_release}"
  env                   = "${var.env}"
  external_network_name = "${var.external_network_name}"
  subnet_cidr           = "${var.subnet_cidr}"
  dns_nameservers       = "${var.dns_nameservers}"
  mercury_public_key    = "${var.mercury_public_key}"
}

# Manages the main servers group
module "cluster" {
  source          = "modules/clusters/"
  os_release      = "${var.os_release}"
  env             = "${var.env}"
  role            = "${var.role}"
  count           = "${var.count}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.flavor_name}"
  network_name    = "${module.environment.main_network_name}"
  affinity        = "${var.affinity}"
  key_pair        = "${module.environment.mercury_keypair}"
  security_groups = [
    "uk-sanger-internal-openstack-${var.os_release}-${var.env}-hgi-secgroup-ping",
    "uk-sanger-internal-openstack-${var.os_release}-${var.env}-hgi-secgroup-ssh",
    "uk-sanger-internal-openstack-${var.os_release}-${var.env}-hgi-secgroup-tcp-local",
    "uk-sanger-internal-openstack-${var.os_release}-${var.env}-hgi-secgroup-udp-local"
  ]
}

/*
 *  module "uk-sanger-internal-openstack-${var.os_release}-gateway" {
 *    source = "../modules/ssh-gateway/"
 *    env    = "${var.env}"
 *  
 *    image = "${module.hgi-openstack-image-hgi-base-freebsd11-4cb02ffa.image}"
 *  
 *    flavor       = "o1.medium"
 *    domain       = "zeta-hgi.hgi.sanger.ac.uk"
 *    core_context = "${module.openstack.context}"
 *  
 *    extra_ansible_groups = ["docker-consul-cluster-zeta-hgi"]
 *  }
 */
