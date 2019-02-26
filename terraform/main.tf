provider "openstack" {
  # Use environment variables for a detailed configuration of this provider:
  #   https://www.terraform.io/docs/providers/openstack/index.html#configuration-reference
  version     = "~> 1.7"
}

module "sanger_internal_openstack_zeta_hgi_systems" {
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
