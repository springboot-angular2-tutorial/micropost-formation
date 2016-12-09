resource "aws_ecs_cluster" "main" {
  name = "micropost"
}

// ------ frontend -------

resource "aws_ecr_repository" "frontend" {
  name = "micropost/frontend"
}

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
  template = "${file("./webservers/task-definitions/frontend.json")}"
  vars {
    account_number = "${data.aws_caller_identity.current.account_id}"
    region = "${data.aws_region.current.id}"
    image_id = "${aws_ecr_repository.frontend.id}"
  }
}

resource "aws_ecs_task_definition" "frontend" {
  family = "micropost-frontend"
  container_definitions = "${data.template_file.frontend_task_definition.rendered}"
}

// ------ backend -------

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
