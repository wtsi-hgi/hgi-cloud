tenant_name               = "hgi-dev"
region                    = "regionOne"
os_release                = "eta"
programme                 = "hgi"
env                       = "dev"

public_key                = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC33E9dReKYHouMSEmSktP3FpGlKiOMcYPVafwIlLkfkdsWOEAOlZZgPUivGqlrhO6swhyB4E/ZxRslT1JWxbq2yt78LbOmkykuiPP0FB1LjGChpx4SwLLDeP9XDaf5Mj5dljp2YWpPYXjEZs7s0hQNXNwJUOUDCGKhTD/F/y7UIpalYxRg4dOlbMcnVJM01f38eLA0bUx1XwERO7gusdX7rwlok/ToilQqIvvbU4bPnK/2JsShX9uQiol/Tk1z5vvF4ezwacS2UwqnksyrIvsivBndrXnN/Ap78lKfuxI1hm1421/GJtadJ1x7+48uwHQUC7oHALf2NWkLwo9XK4KyiSuQJQjhg/lTqm9aaVcPrjcKSX7RyD6PMx+LSxXzUJKqJuxYzVrH3MNr3aD6tEs/4fz0rXALJAi1aQ7PucTSf1hVqlI4hxN7UyfV9cBy/ViLrnLp3HX63MgrtmUgxVm9Mv6krJW/cspJxpbPzHjxx6wtr/0kFbw9affBgNNzth2p8HquK4XiGE19PsuqNBFxLfF0AtYTAlaDn2fZNYqMVaMepUrTV0ZF2WyFoPSkJal7MKw5Xqt5nB5MJnbVDuaRxz35DROHwYauCTsRV5eRMXpvsYd3FUVAGGU9P3N+bPctj2METZS+L3gpXPnVEMqm0D5p4BrP5PY5c1zSlrjlow== mercury@farm3-head4"

external_network_name     = "public"
external_dns_nameservers  = ["172.18.255.1", "172.18.255.2", "172.18.255.3"]

# Networks that offer and internal service
workstations_subnet_cidr  = "192.168.224.0/27"
build_subnet_cidr         = "192.168.224.64/27"
management_subnet_cidr    = "192.168.224.128/27"
local_dns_nameservers     = ["192.168.224.158", "192.168.224.157", "192.168.224.156"]

# Accessories/Clustering/Consensus/Quorum networks
consensus_subnet_cidr     = "192.168.225.0/27"

main_subnet_cidr          = "192.168.226.0/23"
pet_subnet_cidr           = "192.168.255.0/24"
pet_master_address        = "192.168.255.254"

# count                     = 3
# flavor_name               = "o2.small"
# image_name                = "bionic-server"
# affinity                  = "soft-anti-affinity"
