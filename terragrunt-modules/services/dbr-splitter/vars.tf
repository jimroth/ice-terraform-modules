variable "region" {}
variable "env" {}
variable "env_tag" {}
variable "tf_state_bucket" {}
variable "tf_state_region" {}

variable "cidrs" {
  type = "list"
}

variable "key_path" {
  description = "Path to the SSH key PEM file"
}

variable "key_name" {}

variable "instance_type" {
  default = "t2.nano"
}

variable "config_region" {
  description = "Region where the config file S3 bucket is located"
}

variable "config_bucket" {
  description = "S3 bucket name where the config file is located"
}

variable "dbr_bucket" {}
variable "cost_and_usage_bucket" {}

variable "assume_role_resources" {
  description = "List of roles the dbr-splitter is allowed to assume"
  type        = "list"
}
