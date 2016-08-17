variable "es_backup_repository" {
  default = "micropost-log-backups"
}

resource "aws_elasticsearch_domain" "micropost" {
  domain_name = "${var.app}-${var.env}"
  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_account_id}:root"
      },
      "Effect": "Allow",
      "Resource": "arn:aws:es:${var.aws_region}:${var.aws_account_id}:domain/micropost-${var.env}/*"
    },
    {
      "Action": "es:*",
      "Principal": "*",
      "Effect": "Allow",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "${var.segment["office"]}"
        }
      },
      "Resource": "arn:aws:es:${var.aws_region}:${var.aws_account_id}:domain/micropost-${var.env}/*"
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
  tags {
    Name = "${var.app}-${var.env}"
    App = "${var.app}"
    Env = "${var.env}"
  }
  provisioner "local-exec" {
    command = <<EOF
      ruby scripts/es_register_snapshot_directory.rb \
        --host=${aws_elasticsearch_domain.micropost.endpoint} \
        --repository=${var.es_backup_repository} \
        --region=${var.aws_region} \
        --bucket=${aws_s3_bucket.backup.bucket} \
        --role_arn="${aws_iam_role.logbackup.arn}" \
        --base_path=${var.es_backup_repository}
EOF
  }
}

resource "aws_iam_role" "logbackup" {
  name = "${var.app}-${var.env}-logbackup"
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

resource "aws_iam_role_policy" "logbackup" {
  name = "logbackup-client"
  role = "${aws_iam_role.logbackup.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.backup.arn}"
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.backup.arn}/*"
    }
  ]
}
EOF
}
