variable "service_name" {
  description = "The name to use for all the service resources"
}

variable "vpc_id" {
  description = "VPC in which to place the bastion service"
  default     = ""
}

variable "cidrs" {
  description = "List of CIDRs for SSH access to the ice-processor"
  type        = "list"
}

variable "key_name" {
  description = "Key name for ice-processor SSH access"
}

variable "key_path" {
  description = "Key file path for ice-processor SSH access"
}

variable "instance_type" {
  description = "EC2 instance type for ice-processor"
}

variable "subnet_id" {
  description = "VPC subnet for the ice-processor"
}

variable "dbr_bucket" {
  description = "Name of the S3 bucket where detailed billing reports are saved"
}

variable "cau_bucket" {
  description = "Name of the S3 bucket where cost and usage reports are saved"
}

variable "cau_s3_region" {
  description = "Region hosting the cost and usage report s3 bucket"
}

variable "work_bucket" {
  description = "Name of the S3 work bucket"
}

variable "account" {
  description = "Account number for the payer account"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "wake_on_cau" {
  description = "Set S3 event notification to wake processor on the cost and usage report bucket"
  default     = false
}

variable "wake_on_sns" {
  description = "SNS Subscription ARN for waking the processor"
  default     = ""
}

variable "ebs_volume_size" {
  description = "Size in GB of root EBS volume"
  default     = "30"
}