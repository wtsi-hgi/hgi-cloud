resource "openstack_compute_servergroup_v2" "cluster" {
  name      = "uk-sanger-internal-openstack-${var.os_release}-${var.env}-hgi-cluster-${var.role}"
  policies  = ["${var.affinity}"]
}

resource "openstack_compute_floatingip_v2" "public" {
  pool  = "${var.subnetpool_name}"
  count = "${var.count}"
}

resource "openstack_compute_instance_v2" "instance" {
  name            = "uk-sanger-internal-openstack-${var.os_release}-${var.env}-hgi-cluster-${var.role}-${count.index + 1}"
  count           = "${var.count}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.flavor_name}"
  key_pair        = "${var.key_pair}"
  security_groups = [ "${var.security_groups}" ]

  network {
    name = "${var.network_name}"
  }

  # provisioner "remote-exec" {
  #   connection {
  #     user = "${var.ssh_user_name}"
  #     key_file = "${var.ssh_key_file}"
  #   }

  #   inline = [
  #     "sudo apt-get -y update",
  #     "sudo apt-get -y install nginx",
  #     "sudo service nginx start"
  #   ]
  # }
}

resource "openstack_compute_floatingip_associate_v2" "associate" {
  count = "${var.count}"
  floating_ip = "${element(openstack_compute_floatingip_v2.public.*.address, count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.instance.*.id, count.index)}"

}
