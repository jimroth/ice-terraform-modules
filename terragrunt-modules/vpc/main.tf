terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../vpc"

  name                = "ice-${var.vpc_env}"
  cidr                = var.cidr_block
  az                  = "${var.region}a"
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  tags                = var.tags
}
