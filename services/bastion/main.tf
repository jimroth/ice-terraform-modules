#
# Securely Connect to Linux Instances Running in a Private Amazon VPC
#
# See: https://aws.amazon.com/blogs/security/securely-connect-to-linux-instances-running-in-a-private-amazon-vpc/
#

resource "aws_security_group" "bastion_sg" {
  name   = "${var.service_name}-sg"
  vpc_id = "${var.vpc_id}"
  tags   = "${merge(var.tags, map("Name", format("%s-sg", var.service_name)))}"
}

resource "aws_security_group_rule" "inbound_rule" {
  type              = "ingress"
  security_group_id = "${aws_security_group.bastion_sg.id}"

  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = "${var.cidrs}"
}

resource "aws_security_group_rule" "outbound_rule" {
  type              = "egress"
  security_group_id = "${aws_security_group.bastion_sg.id}"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

module "ami" {
  source = "../../helpers/ami"
}

resource "aws_instance" "bastion" {
  ami                         = "${module.ami.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.bastion_sg.id}"]
  subnet_id                   = "${var.subnet_id}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = "8"
  }

  tags = "${merge(var.tags, map("Name", format("%s", var.service_name)))}"
}
