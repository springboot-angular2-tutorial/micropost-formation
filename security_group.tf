resource "aws_security_group" "internal" {
  vpc_id = "${aws_vpc.vpc.id}"
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
  tags {
    Name = "internal"
    Env = "${var.env}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "ssh" {
  vpc_id = "${aws_vpc.vpc.id}"
  name_prefix = "ssh-"
  description = "Allow ssh inbound traffic"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "${var.cidr.office}",
      "115.76.85.4/32",
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
  tags {
    Name = "ssh"
    Env = "${var.env}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "http" {
  vpc_id = "${aws_vpc.vpc.id}"
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
  tags {
    Name = "http"
    Env = "${var.env}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "https" {
  vpc_id = "${aws_vpc.vpc.id}"
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
  tags {
    Name = "https"
    Env = "${var.env}"
  }
  lifecycle {
    create_before_destroy = true
  }
}