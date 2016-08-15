//resource "aws_instance" "bastion" {
//  ami = "${data.aws_ami.ubuntu.id}"
//  instance_type = "t2.micro"
//  subnet_id = "${aws_subnet.public_primary.id}"
//  vpc_security_group_ids = [
//    "${aws_security_group.ssh.id}",
//    "${aws_security_group.internal.id}",
//  ]
//  key_name = "${aws_key_pair.micropost.key_name}"
//  associate_public_ip_address = true
//  tags {
//    Name = "${var.app}-${var.env}-bastion"
//    App = "${var.app}"
//    Env = "${var.env}"
//    Role = "bastion"
//  }
//}