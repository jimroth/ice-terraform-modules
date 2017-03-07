output "private_ip" {
  value = "${aws_instance.ldap.private_ip}"
}

output "security_group" {
  value = "${aws_security_group.ldap_sg.id}"
}
