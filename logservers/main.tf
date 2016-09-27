data "aws_caller_identity" "current" {}

resource "aws_elasticsearch_domain" "main" {
  domain_name = "main2"
  elasticsearch_version = "2.3"
  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Effect": "Allow",
      "Resource": "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/main/*"
    },
    {
      "Action": "es:*",
      "Principal": "*",
      "Effect": "Allow",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "${var.allowed_segments[0]}"
        }
      },
      "Resource": "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/main/*"
    }
  ]
}

CONFIG
  snapshot_options {
    automated_snapshot_start_hour = 23
  }
  cluster_config {
    instance_type = "t2.micro.elasticsearch"
  }
  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp2"
  }
  provisioner "local-exec" {
    command = <<EOF
      ruby scripts/es_register_snapshot_directory.rb \
        --host=${aws_elasticsearch_domain.main.endpoint} \
        --repository=${var.backup_repository} \
        --region=${var.aws_region} \
        --bucket=${var.backup_backet} \
        --role_arn="${aws_iam_role.backup.arn}" \
        --base_path=${var.backup_repository}
EOF
  }
}

resource "aws_iam_role" "backup" {
  name = "logserver-backup"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "backup" {
  name = "logserver-backup"
  role = "${aws_iam_role.backup.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "${var.backup_backet_arn}"
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "${var.backup_backet_arn}/*"
    }
  ]
}
EOF
}
