variable "region" {}
variable "env" {}
variable "tf_state_bucket" {}
variable "tf_state_region" {}

variable "cidrs" {
  type = "list"
}

variable "key_name" {}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "ami" {
  default = ""
}
