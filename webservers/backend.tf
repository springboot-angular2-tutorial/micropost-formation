// ------ service -------

resource "aws_ecs_service" "backend" {
  name = "backend"
  cluster = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.backend.arn}"
  desired_count = 1
  iam_role = "${aws_iam_role.ecs_service.arn}"
  depends_on = [
    "aws_iam_policy_attachment.ecs_service"
  ]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.backend.id}"
    container_name = "backend"
    container_port = "8080"
  }
}

// ------ task -------

data "template_file" "backend_task_definition" {
  template = "${file("./webservers/backend.json")}"
  vars {
    account_number = "${data.aws_caller_identity.current.account_id}"
    region = "${data.aws_region.current.id}"
    env = "${var.env}"
    dbserver_endpoint = "${var.dbserver_endpoint}"
    newrelic_license_key = "${var.newrelic_license_key}"
    log_group_name = "${aws_cloudwatch_log_group.backend.name}"
  }
}

resource "aws_ecs_task_definition" "backend" {
  family = "micropost-backend"
  container_definitions = "${data.template_file.backend_task_definition.rendered}"
}

resource "aws_cloudwatch_log_group" "backend" {
  name = "backend"
}

// ------ application autoscaling -------

resource "aws_appautoscaling_target" "backend" {
  service_namespace = "ecs"
  resource_id = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn = "${aws_iam_role.ecs_autoscale.arn}"
  min_capacity = 1
  max_capacity = 2
}

resource "aws_appautoscaling_policy" "backend_scale_out" {
  name = "backend-ScaleOut-CPU-High"
  resource_id = "${aws_appautoscaling_target.backend.resource_id}"
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  metric_aggregation_type = "Average"
  step_adjustment {
    metric_interval_lower_bound = 0
    scaling_adjustment = 1
  }
}

resource "aws_cloudwatch_metric_alarm" "backend_cpu_high" {
  alarm_name = "backend-CPU-Utilization-High"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = "300"
  statistic = "Average"
  threshold = "80"
  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
    ServiceName = "${aws_ecs_service.backend.name}"
  }
  alarm_actions = [
    "${aws_appautoscaling_policy.backend_scale_out.arn}"
  ]
}

resource "aws_appautoscaling_policy" "backend_scale_in" {
  name = "backend-ScaleIn-CPU-Low"
  resource_id = "${aws_appautoscaling_target.backend.resource_id}"
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  metric_aggregation_type = "Average"
  step_adjustment {
    metric_interval_upper_bound = 0
    scaling_adjustment = -1
  }
}

resource "aws_cloudwatch_metric_alarm" "backend_cpu_low" {
  alarm_name = "backend-CPU-Utilization-Low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = "60"
  statistic = "Average"
  threshold = "5"
  dimensions {
    ClusterName = "${aws_ecs_cluster.main.name}"
    ServiceName = "${aws_ecs_service.backend.name}"
  }
  alarm_actions = [
    "${aws_appautoscaling_policy.backend_scale_in.arn}"
  ]
}
