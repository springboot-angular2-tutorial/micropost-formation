resource "aws_lambda_function" "replace_autoscaling_instances" {
  filename = "functions/replace_autoscaling_instances.zip"
  function_name = "replace_autoscaling_instances"
  role = "${aws_iam_role.replace_autoscaling_instances.arn}"
  handler = "index.handle"
  runtime = "nodejs4.3"
  source_code_hash = "${base64sha256(file("functions/replace_autoscaling_instances.zip"))}"
}

resource "aws_iam_role" "replace_autoscaling_instances" {
  name = "replace_autoscaling_instances"
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

resource "aws_iam_role_policy" "replace_autoscaling_instances" {
  name = "replace_autoscaling_instances"
  role = "${aws_iam_role.replace_autoscaling_instances.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:SetDesiredCapacity",
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_sns_topic_subscription" "replace_autoscaling_instances_when_backend_app_updated" {
  topic_arn = "${var.sns_topic_arn_backend_app_updated}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.replace_autoscaling_instances.arn}"
}

resource "aws_lambda_permission" "replace_autoscaling_instances_when_backend_app_updated" {
  statement_id = "replace_autoscaling_instances_when_backend_app_updated"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.replace_autoscaling_instances.arn}"
  principal = "sns.amazonaws.com"
  source_arn = "${var.sns_topic_arn_backend_app_updated}"
}

resource "aws_sns_topic_subscription" "replace_autoscaling_instances_when_asg_image_updated" {
  topic_arn = "${var.sns_topic_arn_asg_image_updated}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.replace_autoscaling_instances.arn}"
}

resource "aws_lambda_permission" "replace_autoscaling_instances_when_asg_image_updated" {
  statement_id = "replace_autoscaling_instances_when_asg_image_updated"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.replace_autoscaling_instances.arn}"
  principal = "sns.amazonaws.com"
  source_arn = "${var.sns_topic_arn_asg_image_updated}"
}
