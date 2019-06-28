variable "region" {}
variable "env" {}
variable "env_tag" {}
variable "tf_state_bucket" {}
variable "tf_state_region" {}

variable "ice_properties_file" {
  default = "../../config/ice.properties"
}

variable "ssh_cidrs" {
  type = "list"
}

variable "http_cidrs" {
  type = "list"
}

variable "key_path" {
  description = "Path to the SSH key PEM file"
}

variable "key_name" {}

variable "instance_type" {
  default = "t2.small"
}

variable "ssl_creds_dir" {
  description = "Path to folder containing SSL certificate and key files. Files must be named ice.crt and ice.key"
}

variable "ldap_port" {
  default = "10389"
}

variable "ldap_user" {
  default = "admin"
}

variable "ldap_password" {}

variable "ebs_volume_size" {
  description = "Size in GB of root EBS volume"
}