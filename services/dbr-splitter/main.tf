resource "aws_security_group" "dbr_splitter_sg" {
  name   = "${var.service_name}-sg"
  vpc_id = "${var.vpc_id}"
  tags   = "${merge(var.tags, map("Name", format("%s-sg", var.service_name)))}"
}

resource "aws_security_group_rule" "inbound_rule" {
  type              = "ingress"
  security_group_id = "${aws_security_group.dbr_splitter_sg.id}"

  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = "${var.cidrs}"
}

resource "aws_security_group_rule" "outbound_http_rule" {
  type              = "egress"
  security_group_id = "${aws_security_group.dbr_splitter_sg.id}"

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_https_rule" {
  type              = "egress"
  security_group_id = "${aws_security_group.dbr_splitter_sg.id}"

  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

#
# Cloudwatch Log Group
#
resource "aws_cloudwatch_log_group" "dbr_splitter_log_group" {
  name              = "/opt/splitbill/splitbill.log"
  retention_in_days = "30"
  tags              = "${var.tags}"
}

module "ami" {
  source = "../../helpers/ami"
}

module "metrics" {
  source = "../../helpers/metrics"
}

data "template_file" "sb_sh" {
  template = "${file("${path.module}/sb.sh")}"

  vars {
    region = "${var.config_region}"
    bucket = "${var.config_bucket}"
  }
}

data "template_file" "install" {
  template = "${file("${path.module}/install.sh")}"

  vars {
    region = "${var.config_region}"
  }
}

resource "aws_instance" "dbr_splitter" {
  ami                         = "${module.ami.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.dbr_splitter_sg.id}"]
  subnet_id                   = "${var.subnet_id}"
  iam_instance_profile        = "${aws_iam_instance_profile.dbr_splitter_profile.name}"
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
    content     = "${data.template_file.sb_sh.rendered}"
    destination = "/tmp/sb.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.install.rendered}"
    destination = "/tmp/install.sh"
  }

  provisioner "file" {
    source      = "${path.module}/awslogs.conf"
    destination = "/tmp/awslogs.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "/bin/bash /tmp/metrics-install.sh",
      "/bin/bash /tmp/install.sh",
    ]
  }

  root_block_device {
    volume_type = "gp2"
  }

  tags = "${merge(var.tags, map("Name", format("%s", var.service_name)))}"
}
