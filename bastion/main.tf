data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = [
      "*ubuntu-xenial-16.04*"
    ]
  }
  filter {
    name = "architecture"
    values = [
      "x86_64"
    ]
  }
  filter {
    name = "root-device-type"
    values = [
      "ebs"
    ]
  }
  filter {
    name = "virtualization-type"
    values = [
      "hvm"
    ]
  }
  filter {
    name = "block-device-mapping.volume-type"
    values = [
      "gp2"
    ]
  }
  owners = [
    # Canonical
    "099720109477"
  ]
}

resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id = "${var.subnet_id}"
  vpc_security_group_ids = [
    "${var.security_groups}"
  ]
  key_name = "${var.key_name}"
  associate_public_ip_address = true
  tags {
    Name = "bastion"
  }
}