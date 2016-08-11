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
  subnet_id = "${aws_subnet.public_primary.id}"
  security_groups = [
    "${aws_security_group.ssh.id}",
    "${aws_security_group.internal.id}",
  ]
  key_name = "id_rsa"
  associate_public_ip_address = true
  tags {
    Name = "Bastion"
  }
}