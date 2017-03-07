resource "aws_security_group" "ldap_sg" {
  name = "${var.service_name}-sg"
  vpc_id = "${var.vpc_id}"
  tags   = "${merge(var.tags, map("Name", format("%s-sg", var.service_name)))}"
}

resource "aws_security_group_rule" "inbound_ssh_rule" {
  type              = "ingress"
  security_group_id = "${aws_security_group.ldap_sg.id}"

  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${var.bastion_sg}"
}

# Clients will add their security group rules to the ldap-sg, so no need to add any here
#resource "aws_security_group_rule" "inbound_ldap_rule" {
#}

resource "aws_security_group_rule" "outbound_rule" {
  type              = "egress"
  security_group_id = "${aws_security_group.ldap_sg.id}"

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

data "template_file" "install" {
  template = "${file("${path.module}/install.sh")}"

  vars {
    ldap_user     = "${var.ldap_user}"
    ldap_password = "${var.ldap_password}"
  }
}

module "ami" {
  source = "../../helpers/ami"
}

module "metrics" {
  source = "../../helpers/metrics"
}

resource "aws_instance" "ldap" {
  ami                    = "${module.ami.id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.ldap_sg.id}"]
  subnet_id              = "${var.subnet_id}"
  iam_instance_profile   = "${aws_iam_instance_profile.ldap_profile.name}"

  root_block_device {
    volume_type = "gp2"
    volume_size = "8"
  }

  tags = "${merge(var.tags, map("Name", format("%s", var.service_name)))}"

  connection = {
    type         = "ssh"
    agent        = true
    bastion_host = "${var.bastion_host}"
    timeout      = "2m"
    user         = "ec2-user"
    private_key  = "${file("${var.key_path}")}"
  }

  provisioner "file" {
    # Add trailing '/' so files go into /tmp and not /tmp/files
    source      = "${module.metrics.files}/"
    destination = "/tmp"
  }

  provisioner "file" {
    source      = "${path.module}/ldap"
    destination = "/tmp/ldap"
  }

  provisioner "file" {
    content     = "${data.template_file.install.rendered}"
    destination = "/tmp/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "/bin/bash /tmp/metrics-install.sh",
      "/bin/bash /tmp/install.sh",
    ]
  }
}
