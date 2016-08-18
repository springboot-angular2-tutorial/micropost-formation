data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = ["*ubuntu-xenial-16.04*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id = "${module.vpc.public_subnets[0]}"
  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.internal.id}",
  ]
  key_name = "${aws_key_pair.micropost.key_name}"
  associate_public_ip_address = true
  tags {
    Name = "${var.app}-${var.env}-bastion"
    App = "${var.app}"
    Env = "${var.env}"
    Role = "bastion"
  }
}