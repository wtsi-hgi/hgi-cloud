module "keypairs" {
  source              = "../modules/keypairs/"
  env                 = "${var.env}"
  jr17_public_key     = "${var.jr17_public_key}"
  mercury_public_key  = "${var.mercury_public_key}"
}

###############################################################################
# Look up external network id from name
###############################################################################
data "openstack_networking_network_v2" "external" {
  name     = "${var.external_network_name}"
  external = true
}


module "networking" {
  source              = "../modules/networking/"
  env                 = "${var.env}"
  external_network_id = "${data.openstack_networking_network_v2.external.id}"
  subnet_cidr         = "${var.subnet_cidr}"
  dns_nameservers     = "${var.dns_nameservers}"
}

module "secgroups" {
  source  = "../modules/secgroups/"
  env     = "${var.env}"
}

# module "cluster" {
#   source          = "../modules/cluster/"
#   env             = "${var.env}"
#   role            = "${var.role}"
#   count           = "${var.count}"
#   image_name      = "${var.image_name}"
#   flavour_name    = "${var.flavour_name}"
#   network_name    = "${var.network_name}"
#   affinity        = "${var.affinity}"
#   key_pair        = "${module.uk_sanger_internal_openstack_zeta_hgi_keypairs.mercury}"
#   security_groups = "${keys(module.uk_sanger_internal_openstack_zeta_hgi_secgroups)}"
#   subnetpool_id   = "${module.uk_sanger_internal_openstack_zeta_hgi_networking.subnetpool_id}"
#   subnetpool_name = "${module.uk_sanger_internal_openstack_zeta_hgi_networking.subnetpool_name}"
# 
#   depends_on = [
#   ]
# }

/*
 *  module "uk_sanger_internal_openstack_zeta_hgi_ssh-gateway" {
 *    source = "../modules/ssh-gateway/"
 *    env    = "${var.env}"
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
