provider "openstack" {
  # Use environment variables for a detailed configuration of this provider:
  #   https://www.terraform.io/docs/providers/openstack/index.html#configuration-reference
  version     = "~> 1.7"
  tenant_name = "${var.tenant_name}"
  region      = "${var.region}"
  # backend "s3" {
  #   bucket    = "uk-sanger-intenal-cog-hgi-systems"
  #   key       = "/opt/hashicorp.com/terraform/${var.tenant_name}/${var.env}"
  #   endpoint  = "cog.sanger.ac.uk"
  # }
}

module "uk_sanger_internal_openstack_zeta_hgi_systems" {
  source                = "openstack/zeta/"
  region                = "${var.region}"
  env                   = "${var.env}"
  jr17_public_key       = "${var.jr17_public_key}"
  mercury_public_key    = "${var.mercury_public_key}"
  external_network_name = "${var.external_network_name}"
  subnet_cidr           = "${var.subnet_cidr}"
  dns_nameservers       = "${var.dns_nameservers}"
  role                  = "${var.role}"
  count                 = "${var.count}"
  image_name            = "${var.image_name}"
  flavor_name           = "${var.flavor_name}"
  affinity              = "${var.affinity}"
}
