output "mercury_keypair" {
  value = "${module.keypairs.mercury}"
}

output "main_network_name" {
  value = "${module.networking.main_network_name}"
}
