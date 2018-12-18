variable "region" {}
variable "env" {}
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

variable "cau_bucket" {}
variable "cau_s3_region" {}
variable "dbr_bucket" {}
variable "account" {}

variable "wake_on_cau" {
  description = "Set S3 event notification to wake processor on the cost and usage report bucket"
  default     = false
}

variable "wake_on_sns" {
  description = "SNS Subscription ARN for waking the processor"
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}
