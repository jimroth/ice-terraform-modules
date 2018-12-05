variable "service_name" {
  description = "The name to use for all the service resources"
}

variable "vpc_id" {
  description = "VPC in which to place the bastion service"
  default     = ""
}

variable "cidrs" {
  description = "List of CIDRs for SSH access to the bastion"
  type        = "list"
}

variable "key_name" {
  description = "Key name for bastion SSH access"
}

variable "instance_type" {
  description = "EC2 instance type for bastion"
}

variable "subnet_id" {
  description = "VPC subnet for the bastion"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "ami" {
  description = "Optional ami to use for the ec2 instance"
  default     = ""
}
