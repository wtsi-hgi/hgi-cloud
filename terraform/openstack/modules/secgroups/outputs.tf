output "sanger_internal_openstack_zeta_hgi_systems_secgroups" {
  value = {
    consul-client  = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_consul-client.id}"
    consul-server  = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_consul-server.id}"
    http           = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_http.id}"
    http-cogs      = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_http-cogs.id}"
    https          = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_https.id}"
    ping           = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_ping.id}"
    ssh            = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_ssh.id}"
    postgres-local = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_postgres-local.id}"
    tcp-local      = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_tcp-local.id}"
    udp-local      = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_udp-local.id}"
    slurm-master   = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_slurm-master.id}"
    slurm-compute  = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_slurm-compute.id}"
    keep-service   = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_keep-service.id}"
    keep-proxy     = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_keep-proxy.id}"
    netdata        = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_netdata.id}"
    nfs-server     = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_nfs-server.id}"
    krb5           = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_krb5.id}"
    irobot         = "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_irobot.id}"
  }

  depends_on = [
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_consul-client}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_consul-server}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_http}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_http-cogs}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_https}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_ping}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_ssh}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_postgres-local}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_tcp-local}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_udp-local}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_slurm-master}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_slurm-compute}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_keep-service}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_keep-proxy}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_netdata}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_nfs-server}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_krb5}"
    "${openstack_compute_secgroup_v2.sanger_internal_openstack_zeta_hgi_systems_secgroup_irobot}"
  ]
}

