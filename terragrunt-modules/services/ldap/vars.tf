variable "region" {}
variable "env" {}
variable "env_tag" {}
variable "tf_state_bucket" {}
variable "tf_state_region" {}

variable "key_name" {}

variable "key_path" {
  description = "Path to the SSH key PEM file"
}

variable "ldap_port" {
  default = "10389"
}

variable "ldap_user" {
  default = "admin"
}

variable "ldap_password" {}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

