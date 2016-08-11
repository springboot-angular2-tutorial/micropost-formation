data "aws_ami" "micropost_web" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Name"
    values = ["micropost-web"]
  }
}

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

