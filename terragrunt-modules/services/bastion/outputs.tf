output "bastion_sg" {
  value = "${module.bastion.bastion_sg}"
}

output "bastion_host" {
  value = "${module.bastion.bastion_host}"
}
