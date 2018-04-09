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

module "bastion" {
  source = "../../../services/bastion"

  cidrs         = "${var.cidrs}"
  key_name      = "${var.key_name}"
  instance_type = "t2.micro"
  vpc_id        = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_id     = "${data.terraform_remote_state.vpc.public_subnet}"
  service_name  = "bastion-${var.env}"

  tags = "${merge(var.tags, map("Environment", "${var.env_tag}", "Application", "Ice"))}"
}
