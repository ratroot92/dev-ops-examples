variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "instance_type" {}
variable "ssh_public_key" {
  type    = string
  default = "/home/asd/.ssh/id_rsa.pub"

}


variable "ssh_private_key_path" {
  type    = string
  default = "/home/asd/.ssh/id_rsa"

}
