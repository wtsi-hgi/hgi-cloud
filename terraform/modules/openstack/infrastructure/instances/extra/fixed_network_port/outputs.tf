output "port_id" {
  value = "${openstack_networking_port_v2.port.*.id}"
}
