module "uk_sanger_internal_openstack_zeta_hgi_keypairs" {
  source          = "../modules/keypairs/"
  region          = "${var.region}"
  env             = "${var.env}"
  jr17_keypair    = "${var.jr17_public_key}"
  mercury_keypair = "${var.mercury_public_key}"
}

module "uk_sanger_internal_openstack_zeta_hgi_networking" {
  source                = "../modules/networking/"
  region                = "${var.region}"
  env                   = "${var.env}"
  external_network_name = "${var.external_network_name}"
  subnet                = "${var.subnet}"
  dns_nameservers       = "${var.dns_nameservers}"
  host_routes           = "${var.host_routes}"
  gateway_ip            = "${var.gateway_ip}"
}

module "uk_sanger_internal_openstack_zeta_hgi_secgroups" {
  source  = "../modules/secgroups/"
  region  = "${var.region}"
  env     = "${var.env}"
}

module "uk_sanger_internal_openstack_zeta_hgi_cluster" {
  source          = "../modules/cluster/"
  region          = "${var.region}"
  env             = "${var.env}"
  role            = "${var.role}"
  count           = "${var.count}"
  image_name      = "${var.image_name}"
  flavour_name    = "${var.flavour_name}"
  network_name    = "${var.network_name}"
  affinity        = "${var.affinity}"
  key_pair        = "${module.uk_sanger_internal_openstack_zeta_hgi_keypairs.mercury}"
  security_groups = "${keys(module.uk_sanger_internal_openstack_zeta_hgi_secgroups)}"
  subnetpool_id   = "${module.uk_sanger_internal_openstack_zeta_hgi_networking.subnetpool_id}"
  subnetpool_name = "${module.uk_sanger_internal_openstack_zeta_hgi_networking.subnetpool_name}"
}

/*
 *  module "uk_sanger_internal_openstack_zeta_hgi_ssh-gateway" {
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
