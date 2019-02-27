provider "openstack" {
  # Use environment variables for a detailed configuration of this provider:
  #   https://www.terraform.io/docs/providers/openstack/index.html#configuration-reference
  version = "~> 1.7"
  tenant  = "${var.tenant}"
  backend "s3" {
    bucket = "uk-sanger-intenal-cog-hgi-systems"
    key = "/opt/hashicorp.com/terraform/${var.tenant}/${var.env}"
    endpoint = "cog.sanger.ac.uk"
  }
}

module "uk_sanger_internal_openstack_zeta_hgi_systems" {
  source                = "openstack/zeta/"
  region                = "${var.region}"
  env                   = "${var.env}"
  jr17_public_key       = "${var.jr17_public_key}"
  mercury_public_key    = "${var.mercury_public_key}"
  external_network_name = "${var.external_network_name}"
  subnet                = "${var.subnet}"
  dns_nameservers       = "${var.dns_nameservers}"
  host_routes           = "${var.host_routes}"
  gateway_ip            = "${var.gateway_ip}"
}
