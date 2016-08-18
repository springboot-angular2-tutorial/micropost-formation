resource "aws_codedeploy_app" "main" {
  name = "${var.app}-${var.env}"
}

resource "aws_codedeploy_deployment_group" "web" {
  app_name = "${aws_codedeploy_app.main.name}"
  deployment_group_name = "web"
  service_role_arn = "${aws_iam_role.codedeploy_service.arn}"
  autoscaling_groups = ["${module.webservers.asg_id}"]
  deployment_config_name = "CodeDeployDefault.OneAtATime"
}

resource "aws_iam_role" "codedeploy_service" {
  name = "${var.app}-${var.env}-codedeploy-service"
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
                "tag:GetResources"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
