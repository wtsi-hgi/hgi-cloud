data "openstack_networking_network_v2" "sanger_internal_openstack_zeta_hgi_cluster_network" {
  name     = "${var.cluster_network_name}"
  external = true
}

resource "openstack_compute_servergroup_v2" "cluster" {
  name      = "uk_sanger_internal_openstack_zeta_${var.region}_${var.env}_hgi_cluster_${var.name}"
  region    = "${var.region}"
  policies  = ["soft-anti-affinity"]
}

resource "openstack_compute_floatingip_v2" "floatingip" {
  pool  = "${var.subnetpool_name}"
  count = "${var.count}"
}

resource "openstack_compute_instance_v2" "instance" {
  name            = "uk_sanger_internal_openstack_zeta_${var.region}_${var.env}_hgi_cluster_${var.name}_${count.index}"
  count           = "${var.count}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.flavor_name}"
  key_pair        = "${var.key_pair}"
  security_groups = "${var.security_groups}"
  floating_ip     = "${openstack_compute_floatingip_v2.floating_ip.*.address[count.index]}"

  network {
    uuid = "${var.network_uuid}"
  }

  provisioner "remote-exec" {
    connection {
      user = "${var.ssh_user_name}"
      key_file = "${var.ssh_key_file}"
    }

    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start"
    ]
  }
}
