provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "ice_bucket" {
  bucket = "${var.bucket_name}-${var.env}"
  acl    = "private"

  tags {
    Name        = "ice-bucket-${var.env}"
    Environment = "${var.env_tag}"
    Application = "Ice"
  }
}
