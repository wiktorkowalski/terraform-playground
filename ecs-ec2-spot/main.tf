provider "aws" {
  region  = "eu-central-1"
  profile = "default"
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "wojtusdiscord-bot"
}

module "ecs-cluster" {
  source  = "springload/ecs-cluster/aws"
  version = "0.2.5"

  cluster_name  = "terraform"
  spot          = true
  instance_type = "t2.micro"
  ec2_key_name  = "WiktorPC"
}

resource "aws_iam_role" "ecs_service" {
  name = "ecs_service"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Principal": {
        "Service": ["ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:GetParameters", "ssm:DescribeParameters", "ssm:GetParameter","ssm:GetParametersByPath"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role-attatchment" {
  role       = aws_iam_role.ecs_service.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_ecs_task_definition" "task" {
  family        = "nginx"
  task_role_arn = aws_iam_role.ecs_service.arn

  container_definitions = file("task-definition.json")
  depends_on = [
    module.ecs-cluster
  ]
}

resource "aws_ecs_service" "service" {
  name            = "service"
  cluster         = module.ecs-cluster.cluster_arn
  desired_count   = 1
  task_definition = aws_ecs_task_definition.task.arn
  depends_on = [
    aws_ecs_task_definition.task
  ]
}

output "output-cluster-name" {
  value = module.ecs-cluster.cluster_name
}

output "output-cluster-arn" {
  value = module.ecs-cluster.cluster_arn
}
