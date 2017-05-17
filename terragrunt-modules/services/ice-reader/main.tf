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

data "terraform_remote_state" "ldap" {
  backend = "s3"

  config {
    bucket = "${var.tf_state_bucket}"
    key    = "${var.env}/services/ldap/terraform.tfstate"
    region = "${var.tf_state_region}"
  }
}

data "terraform_remote_state" "ice_bucket" {
  backend = "s3"

  config {
    bucket = "${var.tf_state_bucket}"
    key    = "${var.env}/data-storage/ice-bucket/terraform.tfstate"
    region = "${var.tf_state_region}"
  }
}

data "terraform_remote_state" "eip" {
  backend = "s3"

  config {
    bucket = "${var.tf_state_bucket}"
    key    = "global/eip/terraform.tfstate"
    region = "${var.tf_state_region}"
  }
}

data "template_file" "ice_properties" {
  template = "${file("${var.ice_properties_file}")}"

  vars {
    reader                 = "true"
    processor              = "false"
    billing_s3bucketname   = ""
    billing_s3bucketprefix = ""
    work_s3bucketname      = "${data.terraform_remote_state.ice_bucket.bucket}"
    work_s3bucketprefix    = "${var.work_bucket_prefix}"
  }
}

resource "aws_eip_association" "ice_eip_assoc" {
  instance_id   = "${module.ice-reader.instance_id}"
  allocation_id = "${data.terraform_remote_state.eip.ice_eips["${var.region}"]}"
}

module "ice-reader" {
  source = "../../../services/ice-reader"

  ssh_cidrs           = "${var.ssh_cidrs}"
  http_cidrs          = "${var.http_cidrs}"
  key_name            = "${var.key_name}"
  key_path            = "${var.key_path}"
  instance_type       = "${var.instance_type}"
  vpc_id              = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_id           = "${data.terraform_remote_state.vpc.public_subnet}"
  service_name        = "ice-reader-${var.env}"
  ice_properties      = "${data.template_file.ice_properties.rendered}"
  docker_compose_file = "${var.docker_compose_file}"
  ldap_security_group = "${data.terraform_remote_state.ldap.security_group}"
  ssl_creds_dir       = "${var.ssl_creds_dir}"
  ldap_host           = "${data.terraform_remote_state.ldap.private_ip}"
  ldap_port           = "${var.ldap_port}"
  ldap_user           = "${var.ldap_user}"
  ldap_password       = "${var.ldap_password}"
  work_bucket         = "${data.terraform_remote_state.ice_bucket.bucket}"

  tags {
    Environment = "${var.env_tag}"
    Application = "Ice"
  }
}
