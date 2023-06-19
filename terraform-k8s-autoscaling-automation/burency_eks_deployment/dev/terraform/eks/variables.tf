
variable "vpc_cidr_block" {}
variable "env_prefix" {}
variable "instance_types" {}
variable "ssh_public_key" {
  type    = string
  default = "/home/asd/.ssh/id_rsa.pub"

}


variable "ssh_private_key_path" {
  type    = string
  default = "/home/asd/.ssh/id_rsa"

}
