resource "aws_security_group" "ice_reader_sg" {
  name   = "${var.service_name}-sg"
  vpc_id = "${var.vpc_id}"
  tags   = "${merge(var.tags, map("Name", format("%s-sg", var.service_name)))}"
}

resource "aws_security_group_rule" "inbound_ssh_rule" {
  type              = "ingress"
  security_group_id = "${aws_security_group.ice_reader_sg.id}"

  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = "${var.ssh_cidrs}"
}

resource "aws_security_group_rule" "inbound_http_rule" {
  type              = "ingress"
  security_group_id = "${aws_security_group.ice_reader_sg.id}"

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = "${var.http_cidrs}"
}

resource "aws_security_group_rule" "inbound_https_rule" {
  type              = "ingress"
  security_group_id = "${aws_security_group.ice_reader_sg.id}"

  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = "${var.http_cidrs}"
}

resource "aws_security_group_rule" "outbound_http_rule" {
  type              = "egress"
  security_group_id = "${aws_security_group.ice_reader_sg.id}"

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_https_rule" {
  type              = "egress"
  security_group_id = "${aws_security_group.ice_reader_sg.id}"

  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_ldap_rule" {
  type              = "egress"
  security_group_id = "${aws_security_group.ice_reader_sg.id}"

  from_port                = "${var.ldap_port}"
  to_port                  = "${var.ldap_port}"
  protocol                 = "tcp"
  source_security_group_id = "${var.ldap_security_group}"
}

#
# add an ingress rule to the LDAP service security security_group
#
resource "aws_security_group_rule" "inbound_ldap_rule" {
  type              = "ingress"
  security_group_id = "${var.ldap_security_group}"

  from_port                = "${var.ldap_port}"
  to_port                  = "${var.ldap_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.ice_reader_sg.id}"
}

module "ami" {
  source = "../../helpers/ami"
}

module "metrics" {
  source = "../../helpers/metrics"
}

module "ice-install" {
  source = "../../helpers/ice-install"
}

data "template_file" "nginx_conf" {
  template = "${file("${path.module}/nginx.conf")}"

  vars {
    ldap_host     = "${var.ldap_host}"
    ldap_port     = "${var.ldap_port}"
    ldap_user     = "${var.ldap_user}"
    ldap_password = "${var.ldap_password}"
  }
}

resource "aws_instance" "ice_reader" {
  ami                         = "${module.ami.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.ice_reader_sg.id}"]
  subnet_id                   = "${var.subnet_id}"
  iam_instance_profile        = "${aws_iam_instance_profile.ice_reader_profile.name}"
  associate_public_ip_address = true

  connection = {
    type        = "ssh"
    agent       = false
    timeout     = "2m"
    user        = "ec2-user"
    private_key = "${file("${var.key_path}")}"
  }

  provisioner "file" {
    # Add trailing '/' so files go into /tmp and not /tmp/files
    source      = "${module.metrics.files}/"
    destination = "/tmp"
  }

  provisioner "file" {
    # Add trailing '/' so files go into /tmp and not /tmp/files
    source      = "${module.ice-install.files}/"
    destination = "/tmp"
  }

  provisioner "file" {
    content     = "${data.template_file.nginx_conf.rendered}"
    destination = "/tmp/nginx.conf"
  }

  provisioner "local-exec" {
    # Zip up the config and asset files
    command = "zip -r docker-ice.zip docker-ice"
  }

  provisioner "file" {
    source      = "docker-ice.zip"
    destination = "/tmp/docker-ice.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "/bin/bash /tmp/metrics-install.sh",
      "/bin/bash /tmp/ice-install.sh",
    ]
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = "${var.ebs_volume_size}"
  }

  tags = "${merge(var.tags, map("Name", format("%s", var.service_name)))}"
}
