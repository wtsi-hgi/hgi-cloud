# Manages public keys
module "keypairs" {
  source              = "../modules/keypairs/"
  env                 = "${var.env}"
  os_release          = "${var.os_release}"
  mercury_public_key  = "${var.mercury_public_key}"
}

# Manages network, subnet, and router
module "networking" {
  source                = "../modules/networking/"
  env                   = "${var.env}"
  os_release            = "${var.os_release}"
  external_network_name = "${var.external_network_name}"
  subnet_cidr           = "${var.subnet_cidr}"
  dns_nameservers       = "${var.dns_nameservers}"
}

# Manages security groups
module "secgroups" {
  source      = "../modules/secgroups/"
  env         = "${var.env}"
  os_release  = "${var.os_release}"
}

# Manages the main servers group
module "cluster" {
  source          = "../modules/clusters/"
  os_release      = "${var.os_release}"
  env             = "${var.env}"
  role            = "${var.role}"
  count           = "${var.count}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.flavor_name}"
  network_name    = "${module.networking.main_network_name}"
  affinity        = "${var.affinity}"
  key_pair        = "${module.keypairs.mercury}"
  security_groups = ["${values(module.secgroups.name)}"]
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
