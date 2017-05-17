terraform {
  backend "s3" {}
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.tf_state_bucket}"
    key    = "${var.env}/vpc/terraform.tfstate"
    region = "${var.tf_state_region}"
  }
}

provider "aws" {
  region = "${var.region}"
}

module "dbr-splitter" {
  source = "../../../services/dbr-splitter"

  cidrs                 = "${var.cidrs}"
  key_name              = "${var.key_name}"
  key_path              = "${var.key_path}"
  instance_type         = "${var.instance_type}"
  vpc_id                = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_id             = "${data.terraform_remote_state.vpc.public_subnet}"
  service_name          = "dbr-splitter-${var.env}"
  config_region         = "${var.config_region}"
  config_bucket         = "${var.config_bucket}"
  dbr_bucket            = "${var.dbr_bucket}"
  cost_and_usage_bucket = "${var.cost_and_usage_bucket}"

  assume_role_resources = "${var.assume_role_resources}"

  tags {
    Environment = "${var.env_tag}"
    Application = "SplitBill"
  }
}
