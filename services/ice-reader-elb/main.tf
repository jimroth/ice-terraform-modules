resource "aws_security_group" "ice_reader_sg" {
  name   = "${var.service_name}-sg"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, map("Name", format("%s-sg", var.service_name)))
}

resource "aws_security_group_rule" "inbound_ssh_rule" {
  type              = "ingress"
  security_group_id = aws_security_group.ice_reader_sg.id

  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.ssh_cidrs
}

resource "aws_security_group_rule" "inbound_http_rule" {
  type              = "ingress"
  security_group_id = aws_security_group.ice_reader_sg.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = concat(var.http_cidrs, [var.elb_subnet_cidr])
}

resource "aws_security_group_rule" "inbound_http_health_check_rule" {
  type              = "ingress"
  security_group_id = aws_security_group.ice_reader_sg.id

  from_port   = 8000
  to_port     = 8000
  protocol    = "tcp"
  cidr_blocks = [var.elb_subnet_cidr]
}

resource "aws_security_group_rule" "inbound_https_rule" {
  type              = "ingress"
  security_group_id = aws_security_group.ice_reader_sg.id

  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = var.http_cidrs
}

resource "aws_security_group_rule" "outbound_http_rule" {
  type              = "egress"
  security_group_id = aws_security_group.ice_reader_sg.id

  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_http_health_check_rule" {
  type              = "egress"
  security_group_id = aws_security_group.ice_reader_sg.id

  from_port   = 8000
  to_port     = 8000
  protocol    = "tcp"
  cidr_blocks = [var.elb_subnet_cidr]
}

resource "aws_security_group_rule" "outbound_https_rule" {
  type              = "egress"
  security_group_id = aws_security_group.ice_reader_sg.id

  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_elb" "ice_reader_elb" {
  name            = "${var.service_name}-elb"
  subnets         = var.elb_subnets
  security_groups = [aws_security_group.ice_reader_sg.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = var.ssl_certificate_id
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = var.health_check
    interval            = 30
  }

  instances                   = [aws_instance.ice_reader.id]
  cross_zone_load_balancing   = false
  connection_draining         = true
  connection_draining_timeout = 60
  idle_timeout                = 600
  tags                        = merge(var.tags, map("Name", format("%s-%s", var.service_name, "elb")))
}

data "template_file" "default_conf" {
  template = file("${path.module}/default.conf")

  vars = {
    hostname = var.hostname
  }
}

resource "aws_instance" "ice_reader" {
  ami                         = module.ami.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.ice_reader_sg.id]
  subnet_id                   = var.subnet_id
  iam_instance_profile        = aws_iam_instance_profile.ice_reader_profile.name
  associate_public_ip_address = true

  connection {
    type        = "ssh"
    agent       = false
    timeout     = "2m"
    user        = "ec2-user"
    private_key = file(var.key_path)
    host        = self.public_ip
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
    content     = data.template_file.default_conf.rendered
    destination = "/tmp/default.conf"
  }

  provisioner "file" {
    content     = var.vouch_config
    destination = "/tmp/config.yml"
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
    volume_size = var.ebs_volume_size
  }

  tags = merge(var.tags, map("Name", format("%s", var.service_name)))
}
