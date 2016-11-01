data "aws_caller_identity" "current" {}

data "aws_region" "current" {
  current = true
}

resource "aws_codedeploy_app" "main" {
  name = "${var.name}"
}

resource "aws_codedeploy_deployment_group" "main" {
  app_name = "${aws_codedeploy_app.main.name}"
  deployment_group_name = "${var.group_name}"
  service_role_arn = "${aws_iam_role.codedeploy_service.arn}"
  autoscaling_groups = ["${var.autoscaling_groups}"]
  deployment_config_name = "CodeDeployDefault.OneAtATime"
  trigger_configuration {
    trigger_events = [
      "DeploymentSuccess",
      "DeploymentFailure",
    ]
    trigger_name = "frontend_deployed"
    trigger_target_arn = "arn:aws:sns:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:frontend_deployed"
  }
}

resource "aws_iam_role" "codedeploy_service" {
  name = "codedeploy-${var.group_name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "codedeploy.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codedeploy_service_policy" {
  name = "codedeploy-service"
  role = "${aws_iam_role.codedeploy_service.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:CompleteLifecycleAction",
                "autoscaling:DeleteLifecycleHook",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeLifecycleHooks",
                "autoscaling:PutLifecycleHook",
                "autoscaling:RecordLifecycleActionHeartbeat",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "tag:GetTags",
                "tag:GetResources",
                "sns:Publish"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}