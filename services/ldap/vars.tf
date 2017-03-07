variable "service_name" {
  description = "The name to use for all the service resources"
}

variable "vpc_id" {
  description = "VPC in which to place the LDAP service"
  default     = ""
}

variable "bastion_sg" {
  description = "security group of the bastion used for SSH access"
}

variable "bastion_host" {
  description = "Hostname of the bastion server used to connect to the LDAP server"
}

variable "key_name" {
  description = "Key name for SSH access"
}

variable "key_path" {
  description = "Key file path for SSH access"
}

variable "instance_type" {
  description = "EC2 instance type for LDAP server"
}

variable "subnet_id" {
  description = "VPC subnet for the LDAP server"
}

variable "ldap_port" {
  description = "Port number for the LDAP service"
}

variable "ldap_user" {
  description = "LDAP server user name"
}

variable "ldap_password" {
  description = "LDAP server password"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}
