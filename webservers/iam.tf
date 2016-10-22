resource "aws_iam_instance_profile" "web" {
  name = "web"
  roles = [
    "${aws_iam_role.web.name}"
  ]
}

resource "aws_iam_role" "web" {
  name = "web"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "read_s3_to_deploy" {
  name = "read-s3-to-deploy"
  role = "${aws_iam_role.web.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
