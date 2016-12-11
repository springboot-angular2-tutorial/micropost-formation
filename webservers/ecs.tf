resource "aws_ecs_cluster" "main" {
  name = "micropost"
}

// ------ frontend -------

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

// ------ backend -------

resource "aws_ecs_service" "backend" {
  name = "backend"
  cluster = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.backend.arn}"
  desired_count = 1
  iam_role = "${aws_iam_role.ecs_service.arn}"
  depends_on = [
    "aws_iam_role_policy.ecs_service_role_policy"]

  load_balancer {
    target_group_arn = "${aws_alb_target_group.backend.id}"
    container_name = "backend"
    container_port = "8080"
  }
}

data "template_file" "backend_task_definition" {
  template = "${file("./webservers/task_definitions/backend.json")}"
  vars {
    account_number = "${data.aws_caller_identity.current.account_id}"
    region = "${data.aws_region.current.id}"
    env = "${var.env}"
    dbserver_endpoint = "${var.dbserver_endpoint}"
    app_encryption_password = "${var.app_encryption_password}"
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

// ------ iam -------

resource "aws_iam_role" "ecs_service" {
  name = "ecs-service"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name = "ecs-service"
  role = "${aws_iam_role.ecs_service.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
