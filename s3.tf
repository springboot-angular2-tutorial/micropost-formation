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
