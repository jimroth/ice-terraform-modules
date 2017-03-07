# Data source for finding the latest amazon linux ami
# that uses hardware virtualization and an ebs root device
data "aws_ami" "latest" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}

output "name" {
  value = "${data.aws_ami.latest.name}"
}

output "id" {
  value = "${data.aws_ami.latest.id}"
}
