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

data "terraform_remote_state" "ice_bucket" {
  backend = "s3"

  config {
    bucket = "${var.tf_state_bucket}"
    key    = "${var.env}/data-storage/ice-bucket/terraform.tfstate"
    region = "${var.tf_state_region}"
  }
}

data "template_file" "ice_properties" {
  template = "${file("${var.ice_properties_file}")}"

  vars {
    reader                 = "false"
    processor              = "true"
    billing_s3bucketname   = "${var.dbr_bucket}"
    billing_s3bucketprefix = "${var.dbr_bucket_prefix}"
    work_s3bucketname      = "${data.terraform_remote_state.ice_bucket.bucket}"
    work_s3bucketprefix    = "${var.work_bucket_prefix}"
  }
}

module "ice-processor" {
  source = "../../../services/ice-processor"

  cidrs               = "${var.cidrs}"
  key_name            = "${var.key_name}"
  key_path            = "${var.key_path}"
  instance_type       = "${var.instance_type}"
  vpc_id              = "${data.terraform_remote_state.vpc.vpc_id}"
  subnet_id           = "${data.terraform_remote_state.vpc.public_subnet}"
  service_name        = "ice-processor-${var.env}"
  ice_properties      = "${data.template_file.ice_properties.rendered}"
  docker_compose_file = "${var.docker_compose_file}"
  dbr_s3_region       = "${var.dbr_s3_region}"
  dbr_bucket          = "${var.dbr_bucket}"
  work_bucket         = "${data.terraform_remote_state.ice_bucket.bucket}"
  account             = "${var.account}"

  tags {
    Environment = "${var.env_tag}"
    Application = "Ice"
  }
}
