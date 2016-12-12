// ------ service -------

resource "aws_ecs_service" "frontend" {
  name = "frontend"
  cluster = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.frontend.arn}"
  desired_count = 1
  iam_role = "${aws_iam_role.ecs_service.arn}"
  depends_on = [
    "aws_iam_role_policy.ecs_service_role_policy"]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.frontend.id}"
    container_name = "frontend"
    container_port = "80"
  }
}

// ------ task -------

data "template_file" "frontend_task_definition" {
  template = "${file("./webservers/task_definitions/frontend.json")}"
  vars {
    account_number = "${data.aws_caller_identity.current.account_id}"
    region = "${data.aws_region.current.id}"
    log_group_name = "${aws_cloudwatch_log_group.frontend.name}"
  }
}

resource "aws_ecs_task_definition" "frontend" {
  family = "micropost-frontend"
  container_definitions = "${data.template_file.frontend_task_definition.rendered}"
}

resource "aws_cloudwatch_log_group" "frontend" {
  name = "frontend"
}

// ------ application autoscaling -------

resource "aws_appautoscaling_target" "frontend" {
  service_namespace = "ecs"
  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.frontend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn = "${aws_iam_role.ecs_autoscale.arn}"
  min_capacity = 1
  max_capacity = 2
}

resource "aws_appautoscaling_policy" "frontend_scale_out" {
  name = "frontend-ScaleOut-CPU-High"
  resource_id = "${aws_appautoscaling_target.frontend.resource_id}"
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  metric_aggregation_type = "Average"
  step_adjustment {
    metric_interval_lower_bound = 0
    scaling_adjustment = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "frontend_cpu_high" {
  alarm_name = "frontend-CPU-Utilization-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = "120"
  statistic = "Average"
  threshold = "80"
  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
    ServiceName = "${aws_ecs_service.frontend.name}"
  }
  alarm_actions = ["${aws_appautoscaling_policy.frontend_scale_out.arn}"]
}

resource "aws_appautoscaling_policy" "frontend_scale_in" {
  name = "frontend-ScaleIn-CPU-Low"
  resource_id = "${aws_appautoscaling_target.frontend.resource_id}"
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  metric_aggregation_type = "Average"
  step_adjustment {
    metric_interval_upper_bound = 0
    scaling_adjustment = -1
  }
}

resource "aws_cloudwatch_metric_alarm" "frontend_cpu_low" {
  alarm_name = "frontend-CPU-Utilization-Low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = "60"
  statistic = "Average"
  threshold = "5"
  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
    ServiceName = "${aws_ecs_service.frontend.name}"
  }
  alarm_actions = ["${aws_appautoscaling_policy.frontend_scale_in.arn}"]
}
