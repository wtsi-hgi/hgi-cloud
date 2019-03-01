output "sanger_internal_openstack_zeta_hgi_systems_secgroups" {
  value = {
    consul_client  = "${openstack_compute_secgroup_v2.consul_client.id}"
    consul_server  = "${openstack_compute_secgroup_v2.consul_server.id}"
    http           = "${openstack_compute_secgroup_v2.http.id}"
    http_cogs      = "${openstack_compute_secgroup_v2.http_cogs.id}"
    https          = "${openstack_compute_secgroup_v2.https.id}"
    ping           = "${openstack_compute_secgroup_v2.ping.id}"
    ssh            = "${openstack_compute_secgroup_v2.ssh.id}"
    postgres_local = "${openstack_compute_secgroup_v2.postgres_local.id}"
    tcp_local      = "${openstack_compute_secgroup_v2.tcp_local.id}"
    udp_local      = "${openstack_compute_secgroup_v2.udp_local.id}"
    slurm_master   = "${openstack_compute_secgroup_v2.slurm_master.id}"
    slurm_compute  = "${openstack_compute_secgroup_v2.slurm_compute.id}"
    keep_service   = "${openstack_compute_secgroup_v2.keep_service.id}"
    keep_proxy     = "${openstack_compute_secgroup_v2.keep_proxy.id}"
    netdata        = "${openstack_compute_secgroup_v2.netdata.id}"
    nfs_server     = "${openstack_compute_secgroup_v2.nfs_server.id}"
    krb5           = "${openstack_compute_secgroup_v2.krb5.id}"
    irobot         = "${openstack_compute_secgroup_v2.irobot.id}"
  }

  depends_on = [
    "${openstack_compute_secgroup_v2.consul_client}",
    "${openstack_compute_secgroup_v2.consul_server}",
    "${openstack_compute_secgroup_v2.http}",
    "${openstack_compute_secgroup_v2.http_cogs}",
    "${openstack_compute_secgroup_v2.https}",
    "${openstack_compute_secgroup_v2.ping}",
    "${openstack_compute_secgroup_v2.ssh}",
    "${openstack_compute_secgroup_v2.postgres_local}",
    "${openstack_compute_secgroup_v2.tcp_local}",
    "${openstack_compute_secgroup_v2.udp_local}",
    "${openstack_compute_secgroup_v2.slurm_master}",
    "${openstack_compute_secgroup_v2.slurm_compute}",
    "${openstack_compute_secgroup_v2.keep_service}",
    "${openstack_compute_secgroup_v2.keep_proxy}",
    "${openstack_compute_secgroup_v2.netdata}",
    "${openstack_compute_secgroup_v2.nfs_server}",
    "${openstack_compute_secgroup_v2.krb5}",
    "${openstack_compute_secgroup_v2.irobot}"
  ]
}

