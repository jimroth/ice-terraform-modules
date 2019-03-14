variable "region" {}
variable "env" {}

variable "bucket_name" {}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}
