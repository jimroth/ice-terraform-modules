variable "name" {
  description = "Name of the VPC"
}

variable "cidr" {
  description = "CIDR for the VPC"
}

variable "az" {
  description = "Availability zone to place the subnets"
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
}

variable "private_subnet_cidr" {
  description = "CIDR for the private subnet"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map
  default     = {}
}
