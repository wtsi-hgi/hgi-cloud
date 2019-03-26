variable "env" {}
variable "programme" {}
variable "os_release" {}
variable "networks" {
  type = "list"
}
variable "key_pair" {}
variable "security_groups" {
  type = "list"
}

variable "count" {
  default = 1
}

variable "image_name" {
  default = "bionic-server"
}

variable "flavor_name" {
  default = "o2.small"
}

variable "affinity" {
  default = "soft-anti-affinity"
}

variable "subnetpool_name" {
  default = "public"
}

# variable "flavour" {}
# variable "domain" {}
# variable "network_id" {}
# 
# variable "security_group_ids" {
#   type    = "map"
#   default = {}
# }
# 
# variable "key_pair_ids" {
#   type    = "map"
#   default = {}
# }
# 
# variable "image" {
#   type    = "map"
#   default = {}
# }
# 
# variable "extra_ansible_groups" {
#   type    = "list"
#   default = []
# }
# 
# variable "floatingip_pool_name" {
#   default = "nova"
# }
