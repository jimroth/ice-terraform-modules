terraform {
  backend "s3" {}
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.tf_state_bucket}"
    key    = "${var.vpc_env}/vpc/terraform.tfstate"
    region = "${var.tf_state_region}"
  }
}

provider "aws" {
  region = "${var.region}"
}

data "terraform_remote_state" "ice_bucket" {
  backend = "s3"

  config {
    bucket = "${var.tf_state_bucket}"
    key    = "${var.bucket_env}/data-storage/ice-bucket/terraform.tfstate"
    region = "${var.tf_state_region}"
  }
}

module "ice-processor" {
  source = "../../../services/ice-processor"

  cidrs           = "${var.cidrs}"
  key_name        = "${var.key_name}"
  key_path        = "${var.key_path}"
  instance_type   = "${var.instance_type}"
  ebs_volume_size = "${var.ebs_volume_size}"
  vpc_id          = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_id       = "${data.terraform_remote_state.vpc.public_subnet}"
  service_name    = "ice-processor-${var.env}"
  dbr_bucket      = "${var.dbr_bucket}"
  cau_bucket      = "${var.cau_bucket}"
  cau_s3_region   = "${var.cau_s3_region}"
  work_bucket     = "${data.terraform_remote_state.ice_bucket.bucket}"
  account         = "${var.account}"
  wake_on_cau     = "${var.wake_on_cau}"
  wake_on_sns     = "${var.wake_on_sns}"
  tags            = "${var.tags}"
}
