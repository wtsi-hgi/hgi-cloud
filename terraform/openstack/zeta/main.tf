module "sanger_internal_openstack_zeta_hgi_systems_keypairs" {
  source          = "../modules/keypairs/"
  region          = "${var.region}"
  env             = "${var.env}"
  jr17_keypair    = "${var.jr17_public_key}"
  mercury_keypair = "${var.mercury_public_key}"
}

module "sanger_internal_openstack_zeta_hgi_systems_networking" {
  source                = "../modules/networking/"
  region                = "${var.region}"
  env                   = "${var.env}"
  external_network_name = "${var.external_network_name}"
  subnet                = "${var.subnet}"
  dns_nameservers       = "${var.dns_nameservers}"
  host_routes           = "${var.host_routes}"
  gateway_ip            = "${var.gateway_ip}"
}

module "sanger_internal_openstack_zeta_hgi_systems_secgroups" {
  source  = "../modules/secgroups/"
  region  = "${var.region}"
  env     = "${var.env}"
}

/*
 *  module "sanger_internal_openstack_zeta_hgi_systems_ssh-gateway" {
 *    source = "../modules/ssh-gateway/"
 *    env    = "${var.env}"
 *    region = "${var.region}"
 *  
 *    image = "${module.hgi-openstack-image-hgi-base-freebsd11-4cb02ffa.image}"
 *  
 *    flavour      = "o1.medium"
 *    domain       = "zeta-hgi.hgi.sanger.ac.uk"
 *    core_context = "${module.openstack.context}"
 *  
 *    extra_ansible_groups = ["docker-consul-cluster-zeta-hgi"]
 *  }
 */
