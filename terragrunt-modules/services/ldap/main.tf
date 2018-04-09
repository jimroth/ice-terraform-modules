terraform {
  backend "s3" {}
}

provider "aws" {
  region = "${var.region}"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "${var.tf_state_bucket}"
    key    = "${var.env}/vpc/terraform.tfstate"
    region = "${var.tf_state_region}"
  }
}

data "terraform_remote_state" "bastion" {
  backend = "s3"

  config {
    bucket = "${var.tf_state_bucket}"
    key    = "${var.env}/services/bastion/terraform.tfstate"
    region = "${var.tf_state_region}"
  }
}

module "ldap" {
  source = "../../../services/ldap"

  bastion_sg = "${data.terraform_remote_state.bastion.bastion_sg}"

  #
  # Bastion should have an elastic IP address so that the
  # bastion_host value doesn't change due to stop/start of instance
  #
  bastion_host = "${data.terraform_remote_state.bastion.bastion_host}"

  key_name      = "${var.key_name}"
  key_path      = "${var.key_path}"
  instance_type = "t2.micro"
  vpc_id        = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_id     = "${data.terraform_remote_state.vpc.private_subnet}"
  service_name  = "ldap-${var.env}"
  ldap_port     = "${var.ldap_port}"
  ldap_user     = "${var.ldap_user}"
  ldap_password = "${var.ldap_password}"

  tags = "${merge(var.tags, map("Environment", "${var.env_tag}", "Application", "Ice"))}"
}
