output "name" {
  value = {
    ping           = "${openstack_compute_secgroup_v2.ping.name}"
    ssh            = "${openstack_compute_secgroup_v2.ssh.name}"
    tcp_local      = "${openstack_compute_secgroup_v2.tcp_local.name}"
    udp_local      = "${openstack_compute_secgroup_v2.udp_local.name}"
#     consul_client  = "${openstack_compute_secgroup_v2.consul_client.name}"
#     consul_server  = "${openstack_compute_secgroup_v2.consul_server.name}"
#     http           = "${openstack_compute_secgroup_v2.http.name}"
#     http_cogs      = "${openstack_compute_secgroup_v2.http_cogs.name}"
#     https          = "${openstack_compute_secgroup_v2.https.name}"
#     postgres_local = "${openstack_compute_secgroup_v2.postgres_local.name}"
#     slurm_master   = "${openstack_compute_secgroup_v2.slurm_master.name}"
#     slurm_compute  = "${openstack_compute_secgroup_v2.slurm_compute.name}"
#     keep_service   = "${openstack_compute_secgroup_v2.keep_service.name}"
#     keep_proxy     = "${openstack_compute_secgroup_v2.keep_proxy.name}"
#     netdata        = "${openstack_compute_secgroup_v2.netdata.name}"
#     nfs_server     = "${openstack_compute_secgroup_v2.nfs_server.name}"
#     krb5           = "${openstack_compute_secgroup_v2.krb5.name}"
#     irobot         = "${openstack_compute_secgroup_v2.irobot.name}"
  }

  depends_on = [
    "${openstack_compute_secgroup_v2.ping}",
    "${openstack_compute_secgroup_v2.ssh}",
    "${openstack_compute_secgroup_v2.tcp_local}",
    "${openstack_compute_secgroup_v2.udp_local}"
#     "${openstack_compute_secgroup_v2.consul_client}",
#     "${openstack_compute_secgroup_v2.consul_server}",
#     "${openstack_compute_secgroup_v2.http}",
#     "${openstack_compute_secgroup_v2.http_cogs}",
#     "${openstack_compute_secgroup_v2.https}",
#     "${openstack_compute_secgroup_v2.postgres_local}",
#     "${openstack_compute_secgroup_v2.slurm_master}",
#     "${openstack_compute_secgroup_v2.slurm_compute}",
#     "${openstack_compute_secgroup_v2.keep_service}",
#     "${openstack_compute_secgroup_v2.keep_proxy}",
#     "${openstack_compute_secgroup_v2.netdata}",
#     "${openstack_compute_secgroup_v2.nfs_server}",
#     "${openstack_compute_secgroup_v2.krb5}",
#     "${openstack_compute_secgroup_v2.irobot}"
  ]
}

