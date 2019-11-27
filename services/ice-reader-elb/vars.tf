variable "service_name" {
  description = "The name to use for all the service resources"
}

variable "vpc_id" {
  description = "VPC in which to place the bastion service"
  default     = ""
}

variable "ssh_cidrs" {
  description = "List of CIDRs for SSH access to the ice-reader"
  type        = list
}

variable "http_cidrs" {
  description = "List of CIDRs for HTTP/HTTPS access to the ice-reader"
  type        = list
}

variable "elb_subnet_cidr" {
  description = "Subnet CIDR where the ELB resides"
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

variable "work_bucket" {
  description = "Name of the S3 work bucket"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map
  default     = {}
}

variable "ssl_certificate_id" {
  description = "ARN for the ssl certificate to be used by the ELB"
}

variable "elb_subnets" {
  description = "Subnets for the ELB"
  type        = list
}

variable "vouch_config" {
  description = "Vouch config.yml file content"
}

variable "hostname" {
  description = "Host name for the server"
}

variable "health_check" {
  description = "Health check target for the ELB"
}

variable "ebs_volume_size" {
  description = "Size in GB of root EBS volume"
  default     = "30"
}
