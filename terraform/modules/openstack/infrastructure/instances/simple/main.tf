resource "openstack_compute_servergroup_v2" "servergroup" {
  name      = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-servergroup-${var.role}"
  policies  = ["${var.affinity}"]
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh.tpl")}"
  vars = {
    role = "${var.role}"
    facts = "${var.facts}"
  }
}

resource "openstack_compute_instance_v2" "instance" {
  name            = "uk-sanger-internal-openstack-${var.os_release}-${var.programme}-${var.env}-instance-${var.role}-${count.index + 1}"
  count           = "${var.count}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.flavor_name}"
  key_pair        = "${var.key_pair}"
  security_groups = "${var.security_groups}"

  network = ["${var.networks}"]

  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.servergroup.id}"
  }

  user_data = "${data.template_file.user_data.rendered}"

#   provisioner "remote-exec" {
#     connection {
#       user = "${var.ssh_user_name}"
#       key_file = "${var.ssh_key_file}"
#     }
 
#     inline = [
#       "sudo apt-get -y update",
#       "sudo apt-get -y install nginx",
#       "sudo service nginx start"
#     ]
#   }
}

# resource "openstack_compute_floatingip_v2" "public" {
#   pool  = "${var.subnetpool_name}"
#   count = "${var.count}"
# }
# 
# resource "openstack_compute_floatingip_associate_v2" "associate" {
#   count = "${var.count}"
#   floating_ip = "${element(openstack_compute_floatingip_v2.public.*.address, count.index)}"
#   instance_id = "${element(openstack_compute_instance_v2.instance.*.id, count.index)}"
# }
