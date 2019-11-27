terraform {
  backend "s3" {}
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.tf_state_bucket
    key    = "${var.vpc_env}/vpc/terraform.tfstate"
    region = var.tf_state_region
  }
}

provider "aws" {
  region = var.region
}

data "terraform_remote_state" "ice_bucket" {
  backend = "s3"

  config = {
    bucket = var.tf_state_bucket
    key    = "${var.bucket_env}/data-storage/ice-bucket/terraform.tfstate"
    region = var.tf_state_region
  }
}

data "aws_secretsmanager_secret_version" "client_secrets" {
  secret_id = var.client_secrets
}

data "template_file" "vouch_config" {
  template = file(var.vouch_config_file)

  vars = {
    client_id     = data.external.json.result.client_id
    client_secret = data.external.json.result.client_secret
    hostname      = var.hostname
  }
}

data "external" "json" {
  program = ["echo", data.aws_secretsmanager_secret_version.client_secrets.secret_string]
}

module "ice-reader-elb" {
  source = "../../../services/ice-reader-elb"

  ssh_cidrs          = var.ssh_cidrs
  http_cidrs         = var.http_cidrs
  key_name           = var.key_name
  key_path           = var.key_path
  instance_type      = var.instance_type
  ebs_volume_size    = var.ebs_volume_size
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_id          = data.terraform_remote_state.vpc.outputs.public_subnet
  service_name       = "ice-reader-${var.env}"
  work_bucket        = data.terraform_remote_state.ice_bucket.outputs.bucket
  tags               = var.tags
  ssl_certificate_id = var.ssl_certificate_id
  elb_subnets        = var.elb_subnets
  vouch_config       = data.template_file.vouch_config.rendered
  hostname           = var.hostname
  health_check       = var.health_check
  elb_subnet_cidr    = var.elb_subnet_cidr
}
