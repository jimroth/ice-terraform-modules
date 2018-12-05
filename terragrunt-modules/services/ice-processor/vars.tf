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
  default = "t2.small"
}

variable "docker_compose_file" {
  default = "docker-compose-ec2-processor.yml"
}

variable "dbr_s3_region" {}
variable "cau_bucket" {}
variable "dbr_bucket" {}

variable "work_bucket_prefix" {
  default = ""
}

variable "account" {}

variable "ice_properties_file" {
  default = "../../config/ice.properties"
}

variable "wake_on_cau" {
  default = false
}
