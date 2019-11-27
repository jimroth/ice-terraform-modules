output "private_subnet" {
  value = module.vpc.private_subnet
}

output "public_subnet" {
  value = module.vpc.public_subnet
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "region" {
  value = var.region
}

output "vpc_cidr_block" {
  value = var.cidr_block
}
