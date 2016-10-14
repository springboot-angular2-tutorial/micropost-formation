resource "aws_s3_bucket" "deploy" {
  bucket = "deploy-${var.env}.${var.domain}"
  force_destroy = true
}

resource "aws_s3_bucket" "cdn" {
  bucket = "cdn-${var.env}.${var.domain}"
  acl = "public-read"
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"PublicReadForGetBucketObjects",
        "Effect":"Allow",
      "Principal": "*",
      "Action":"s3:GetObject",
      "Resource":["arn:aws:s3:::cdn-${var.env}.${var.domain}/*"
      ]
    }
  ]
}
POLICY
  force_destroy = true
  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket" "log" {
  bucket = "log-${var.env}.${var.domain}"
  force_destroy = true
  policy = <<CONFIG
{
  "Id": "LogBucketPolicy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "WriteAccess",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::log-${var.env}.${var.domain}/alb-web/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
      "Principal": {
        "AWS":"arn:aws:iam::582318560864:root"
      }
    }
  ]
}
CONFIG
}
