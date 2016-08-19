resource "aws_security_group" "internal" {
  vpc_id = "${var.vpc_id}"
  name_prefix = "internal-"
  description = "Allow internal traffic"
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    self = true
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "internal"
  }
}

resource "aws_security_group" "internet_in_ssh" {
  vpc_id = "${var.vpc_id}"
  name_prefix = "ssh-"
  description = "Allow ssh inbound traffic"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "${var.ssh_allowed_segments}"
    ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "internet-in-ssh"
  }
}

resource "aws_security_group" "internet_in_http" {
  vpc_id = "${var.vpc_id}"
  name_prefix = "http-"
  description = "Allow http inbound traffic"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "internet-in-http"
  }
}

resource "aws_security_group" "internet_in_https" {
  vpc_id = "${var.vpc_id}"
  name_prefix = "https-"
  description = "Allow https inbound traffic"
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "internet-in-https"
  }
}