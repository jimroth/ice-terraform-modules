output "private_ip" {
  value = "${module.ldap.private_ip}"
}

output "security_group" {
  value = "${module.ldap.security_group}"
}
