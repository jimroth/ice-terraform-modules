output "bastion_sg" {
  value = "${aws_security_group.bastion_sg.id}"
}

output "bastion_host" {
  value = "${aws_instance.bastion.public_dns}"
}
