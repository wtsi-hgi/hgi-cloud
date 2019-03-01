###############################################################################
# Security Groups
###############################################################################

resource "openstack_compute_secgroup_v2" "ping" {
  name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_ping"
  description = "ICMP ping"

  # All ICMP
  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}

# resource "openstack_compute_secgroup_v2" "consul_server" {
#   name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_consul_server"
#   description = "Access to consul server agent"
# 
#   # Server RPC
#   rule {
#     from_port   = 8300
#     to_port     = 8300
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
# 
#   # serf LAN/WAN TCP
#   rule {
#     from_port   = 8301
#     to_port     = 8302
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
# 
#   # serf LAN/WAN UDP
#   rule {
#     from_port   = 8301
#     to_port     = 8302
#     ip_protocol = "udp"
#     cidr        = "0.0.0.0/0"
#   }
# 
#   # HTTP API
#   rule {
#     from_port   = 8500
#     to_port     = 8500
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
# 
#   # DNS TCP
#   rule {
#     from_port   = 8600
#     to_port     = 8600
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
# 
#   # DNS UDP
#   rule {
#     from_port   = 8600
#     to_port     = 8600
#     ip_protocol = "udp"
#     cidr        = "0.0.0.0/0"
#   }
# }
# 
# resource "openstack_compute_secgroup_v2" "consul_client" {
#   name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_consul_client"
#   description = "Access to consul client agent"
# 
#   # serf LAN TCP
#   rule {
#     from_port   = 8301
#     to_port     = 8301
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
# 
#   # serf LAN UDP
#   rule {
#     from_port   = 8301
#     to_port     = 8301
#     ip_protocol = "udp"
#     cidr        = "0.0.0.0/0"
#   }
# }
# 
# resource "openstack_compute_secgroup_v2" "http" {
#   name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_http"
#   description = "Incoming http access"
# 
#   rule {
#     from_port   = 80
#     to_port     = 80
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
# }
# 
# resource "openstack_compute_secgroup_v2" "http_cogs" {
#   name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_http_cogs"
#   description = "Incoming http access for studentportal development"
# 
#   rule {
#     from_port   = 8000
#     to_port     = 8100
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
# }
# 
# resource "openstack_compute_secgroup_v2" "https" {
#   name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_https"
#   description = "Incoming https access"
# 
#   rule {
#     from_port   = 443
#     to_port     = 443
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
# }

resource "openstack_compute_secgroup_v2" "ssh" {
  name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_ssh"
  description = "Incoming ssh access"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

# resource "openstack_compute_secgroup_v2" "postgres_local" {
#   name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_postgres_local"
#   description = "Local network access on postgres port 5432"
# 
#   rule {
#     from_port   = 5432
#     to_port     = 5432
#     ip_protocol = "tcp"
#     cidr        = "10.0.0.0/8"
#   }
# }
# 
resource "openstack_compute_secgroup_v2" "tcp_local" {
  name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_tcp_local"
  description = "Local network access from all TCP ports"

  rule {
    from_port   = 1
    to_port     = 65535
    ip_protocol = "tcp"
    cidr        = "10.0.0.0/8"
  }
}

resource "openstack_compute_secgroup_v2" "udp_local" {
  name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_udp_local"
  description = "Local network access from all UDP ports"

  rule {
    from_port   = 1
    to_port     = 65535
    ip_protocol = "udp"
    cidr        = "10.0.0.0/8"
  }
}
# 
# resource "openstack_compute_secgroup_v2" "slurm_master" {
#   name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_slurm_master"
#   description = "Slurm master node"
# 
#   rule {
#     from_port   = 6817
#     to_port     = 6817
#     ip_protocol = "tcp"
#     cidr        = "10.0.0.0/8"
#   }
# 
#   rule {
#     from_port   = 6819
#     to_port     = 6819
#     ip_protocol = "tcp"
#     cidr        = "10.0.0.0/8"
#   }
# 
#   rule {
#     from_port   = 7321
#     to_port     = 7321
#     ip_protocol = "tcp"
#     cidr        = "10.0.0.0/8"
#   }
# }
# 
# resource "openstack_compute_secgroup_v2" "slurm_compute" {
#   name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_slurm_compute"
#   description = "Slurm compute node"
# 
#   rule {
#     from_port   = 6818
#     to_port     = 6818
#     ip_protocol = "tcp"
#     cidr        = "10.0.0.0/8"
#   }
# }
# 
# resource "openstack_compute_secgroup_v2" "keep_service" {
#   name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_keep_service"
#   description = "Arvados keep service"
# 
#   rule {
#     from_port   = 25107
#     to_port     = 25107
#     ip_protocol = "tcp"
#     cidr        = "10.0.0.0/8"
#   }
# }
# 
# resource "openstack_compute_secgroup_v2" "keep_proxy" {
#   name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_keep_proxy"
#   description = "Arvados keep proxy (keep service accessible from anywhere)"
# 
#   rule {
#     from_port   = 25107
#     to_port     = 25107
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
# }
# 
# resource "openstack_compute_secgroup_v2" "netdata" {
#   name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_netdata"
#   description = "Netdata web UI accessible from within tenant network"
# 
#   rule {
#     from_port   = 19999
#     to_port     = 19999
#     ip_protocol = "tcp"
#     cidr        = "10.0.0.0/8"
#   }
# }
# 
# resource "openstack_compute_secgroup_v2" "nfs_server" {
#   name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_nfs_server"
#   description = "NFS server"
# 
#   rule {
#     from_port   = 111
#     to_port     = 111
#     ip_protocol = "tcp"
#     cidr        = "10.0.0.0/8"
#   }
# 
#   rule {
#     from_port   = 111
#     to_port     = 111
#     ip_protocol = "udp"
#     cidr        = "10.0.0.0/8"
#   }
# 
#   rule {
#     from_port   = 2049
#     to_port     = 2049
#     ip_protocol = "tcp"
#     cidr        = "10.0.0.0/8"
#   }
# 
#   rule {
#     from_port   = 2049
#     to_port     = 2049
#     ip_protocol = "udp"
#     cidr        = "10.0.0.0/8"
#   }
# }
# 
# resource "openstack_compute_secgroup_v2" "krb5" {
#   name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_krb5"
#   description = "Kerberos authentication"
# 
#   rule {
#     from_port   = 88
#     to_port     = 88
#     ip_protocol = "udp"
#     cidr        = "0.0.0.0/0"
#   }
# }
# 
# resource "openstack_compute_secgroup_v2" "irobot" {
#   name        = "uk_sanger_internal_openstack_zeta_${var.env}_hgi_secgroup_irobot"
#   description = "iRobot"
# 
#   rule {
#     from_port   = 5000
#     to_port     = 5000
#     ip_protocol = "tcp"
#     cidr        = "0.0.0.0/0"
#   }
# }
