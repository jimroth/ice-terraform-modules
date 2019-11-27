variable "region" {}
variable "env" {}

variable "vpc_env" {
  description = "environment holding the VPC backend state"
}

variable "bucket_env" {
  description = "environment holding the Work bucket backend state"
}

variable "tf_state_bucket" {}
variable "tf_state_region" {}

variable "ssh_cidrs" {
  type = list
}

variable "http_cidrs" {
  type = list
}

variable "elb_subnet_cidr" {
  description = "Subnet CIDR where the ELB resides"
}

variable "key_path" {
  description = "Path to the SSH key PEM file"
}

variable "key_name" {}

variable "instance_type" {
  default = "t2.small"
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

variable "vouch_config_file" {
  description = "Vouch config.yml file"
}

variable "hostname" {
  description = "Host name for the server"
}

variable "client_secrets" {
  description = "Secret name for Vouch Config client secrets stored in AWS Secrets Manager"
}

variable "health_check" {
  description = "Health check target for the ELB"
}

variable "ebs_volume_size" {
  description = "Size in GB of root EBS volume"
}