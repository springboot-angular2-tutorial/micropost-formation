// ------ cluster -------

resource "aws_ecs_cluster" "main" {
  name = "micropost"
}

// ------ iam for ecs service -------

resource "aws_iam_role" "ecs_service" {
  name = "ecs-service"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
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

resource "aws_iam_policy_attachment" "ecs_service" {
  name = "ecs-service"
  roles = ["${aws_iam_role.ecs_service.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

// ------ iam for application autoscaling -------

resource "aws_iam_role" "ecs_autoscale" {
  name = "ecs-autoscale"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ecs_autoscale" {
  name = "ecs-autoscale"
  roles = ["${aws_iam_role.ecs_autoscale.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}
