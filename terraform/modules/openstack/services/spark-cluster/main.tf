module "spark_master" {
  source          = "../../infrastructure/instances/simple/"
  os_release      = "${var.os_release}"
  programme       = "${var.programme}"
  env             = "${var.env}"
  role            = "spark-master"
  count           = "${var.spark_masters}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.flavor_name}"
  affinity        = "${var.affinity}"
  networks        = "${var.networks}"
  key_pair        = "${var.key_pair}"
  security_groups = "${var.security_groups}"
}

module "spark_slaves" {
  source          = "../../infrastructure/instances/simple/"
  os_release      = "${var.os_release}"
  programme       = "${var.programme}"
  env             = "${var.env}"
  role            = "spark-slave"
  count           = "${var.spark_slaves}"
  image_name      = "${var.image_name}"
  flavor_name     = "${var.flavor_name}"
  affinity        = "${var.affinity}"
  networks        = "${var.networks}"
  key_pair        = "${var.key_pair}"
  security_groups = "${var.security_groups}"
}
