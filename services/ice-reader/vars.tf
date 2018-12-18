variable "service_name" {
  description = "The name to use for all the service resources"
}

variable "vpc_id" {
  description = "VPC in which to place the bastion service"
  default     = ""
}

variable "ssh_cidrs" {
  description = "List of CIDRs for SSH access to the ice-reader"
  type        = "list"
}

variable "http_cidrs" {
  description = "List of CIDRs for HTTP/HTTPS access to the ice-reader"
  type        = "list"
}

variable "key_name" {
  description = "Key name for ice-reader SSH access"
}

variable "key_path" {
  description = "Key file path for ice-reader SSH access"
}

variable "instance_type" {
  description = "EC2 instance type for ice-reader"
}

variable "subnet_id" {
  description = "VPC subnet for the ice-reader"
}

variable "ssl_creds_dir" {
  description = "Path to folder containing SSL certificate and key files. Files must be named ice.crt and ice.key"
}

variable "ldap_security_group" {
  description = "Security group of the LDAP server"
}

variable "ldap_host" {
  description = "Hostname of the LDAP server"
}

variable "ldap_port" {
  description = "Port number to use for LDAP requests"
}

variable "ldap_user" {
  description = "LDAP server user name"
}

variable "ldap_password" {
  description = "LDAP server password"
}

variable "work_bucket" {
  description = "Name of the S3 work bucket"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}
