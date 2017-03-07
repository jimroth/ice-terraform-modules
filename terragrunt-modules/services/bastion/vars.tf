variable "region" {}
variable "env" {}
variable "env_tag" {}
variable "tf_state_bucket" {}
variable "tf_state_region" {}

variable "cidrs" {
  type = "list"
}

variable "key_name" {}
