# provider "openstack" { version = "~> 1.16" }
# provider "template" { version = "~> 2.1" }

# FIXME: with terraform > 0.12
# user_data = "${templatefile("${path.module}/user_data.sh.tpl", merge(local.metadata, map("count", format("%02d", count.index + 1))))}"
data "template_file" "user_data" {
  count = "${var.count}"
  template = "${file("${path.module}/user_data.sh.tpl")}"
  vars = "${merge(var.template_vars, map("count", count.index))}"
}
