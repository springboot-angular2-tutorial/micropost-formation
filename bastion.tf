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