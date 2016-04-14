resource "aws_elasticsearch_domain" "logserver" {
  domain_name = "micropost-${var.env}"
  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_account_num}:root"
      },
      "Effect": "Allow",
      "Resource": "arn:aws:es:${var.aws_region}:${var.aws_account_num}:domain/micropost-${var.env}/*"
    },
    {
      "Action": "es:*",
      "Principal": "*",
      "Effect": "Allow",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "${var.segment.office}"
        }
      },
      "Resource": "arn:aws:es:${var.aws_region}:${var.aws_account_num}:domain/micropost-${var.env}/*"
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
}