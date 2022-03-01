provider "aws" {
  region  = "eu-central-1"
  profile = "default"
}

module "ecs-cluster" {
  source  = "springload/ecs-cluster/aws"
  version = "0.2.5"

  cluster_name  = "terraform"
  spot          = true
  instance_type = "t2.micro"
  ec2_key_name  = "WiktorPC"
}

resource "aws_ecs_task_definition" "task" {
  family = "nginx"

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
