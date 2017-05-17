variable "service_name" {
  description = "The name to use for all the service resources"
}

variable "vpc_id" {
  description = "VPC in which to place the bastion service"
  default     = ""
}

variable "cidrs" {
  description = "List of CIDRs for SSH access to the dbr-splitter"
  type        = "list"
}

variable "key_name" {
  description = "Key name for dbr-splitter SSH access"
}

variable "key_path" {
  description = "Key file path for dbr-splitter SSH access"
}

variable "instance_type" {
  description = "EC2 instance type for dbr-splitter"
}

variable "subnet_id" {
  description = "VPC subnet for the dbr-splitter"
}

variable "config_region" {
  description = "Region where the config file S3 bucket is located"
}

variable "config_bucket" {
  description = "S3 bucket name where the config file is located"
}

variable "dbr_bucket" {
  description = "Name of the S3 bucket where detailed billing reports are saved"
}

variable "cost_and_usage_bucket" {
  description = "Name of the S3 bucket where cost and usage reports are saved"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "assume_role_resources" {
  description = "List of roles the dbr-splitter is allowed to assume"
  type        = "list"
}
