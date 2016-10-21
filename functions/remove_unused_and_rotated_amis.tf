resource "aws_lambda_function" "remove_unused_and_rotated_amis" {
  filename = "functions/remove_unused_and_rotated_amis.zip"
  function_name = "remove_unused_and_rotated_amis"
  role = "${aws_iam_role.remove_unused_and_rotated_amis.arn}"
  handler = "index.handle"
  runtime = "nodejs4.3"
  source_code_hash = "${base64sha256(file("functions/remove_unused_and_rotated_amis.zip"))}"
}

resource "aws_iam_role" "remove_unused_and_rotated_amis" {
  name = "remove_unused_and_rotated_amis"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "remove_unused_and_rotated_amis" {
  name = "remove_unused_and_rotated_amis"
  role = "${aws_iam_role.remove_unused_and_rotated_amis.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeImages",
        "ec2:DeregisterImage",
        "ec2:DeleteSnapshot",
        "autoscaling:DescribeLaunchConfigurations",
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_sns_topic_subscription" "remove_unused_and_rotated_amis_when_asg_image_updated" {
  topic_arn = "${var.sns_topic_arn_asg_image_updated}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.remove_unused_and_rotated_amis.arn}"
}

resource "aws_lambda_permission" "remove_unused_and_rotated_amis_when_asg_image_updated" {
  statement_id = "remove_unused_and_rotated_amis_when_asg_image_updated"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.remove_unused_and_rotated_amis.arn}"
  principal = "sns.amazonaws.com"
  source_arn = "${var.sns_topic_arn_asg_image_updated}"
}
