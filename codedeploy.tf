resource "aws_codedeploy_app" "micropost" {
  name = "micropost-${var.env}"
}

resource "aws_codedeploy_deployment_group" "web" {
  app_name = "${aws_codedeploy_app.micropost.name}"
  deployment_group_name = "web"
  service_role_arn = "${aws_iam_role.codedeploy_service.arn}"
  autoscaling_groups = ["${aws_autoscaling_group.web.id}"]
  deployment_config_name = "CodeDeployDefault.OneAtATime"
}
