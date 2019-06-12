variable "volume_ids" {
  type = "list"
}
variable "instance_ids" {
  type = "list"
}
variable "depends_on" {
  default = ""
}
variable "count" {
  default = 1
}
