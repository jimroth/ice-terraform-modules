terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "ice_bucket" {
  bucket = "${var.bucket_name}-${var.env}"
  acl    = "private"
  tags   = var.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
