variable "region" {}
variable "vpc_env" {}

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map
  default     = {}
}

variable "cidr_block" {
  default = "172.31.0.0/16"
}

variable "public_subnet_cidr" {
  default = "172.31.0.0/20"
}

variable "private_subnet_cidr" {
  default = "172.31.16.0/20"
}
