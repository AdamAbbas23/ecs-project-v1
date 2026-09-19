resource "aws_ecs_cluster" "ecs-cluster" {
  name = "ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}
resource "aws_ecs_task_definition" "ecs-service" {
    family = "service"
    requires_compatibilities = ["FARGATE"]
    network_mode = "awsvpc"
    execution_role_arn = var.execution_role_arn
    cpu       = 256
    memory    = 512
container_definitions = jsonencode([
  {
    name      = "ecs"
    image     = "${var.ecr_image_url}:${var.image_tag}"
    essential = true
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/ecs-service"
        "awslogs-region"        = "eu-west-2"
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }
])
  runtime_platform {
  operating_system_family = "LINUX"
  cpu_architecture        = "ARM64"
}
}
resource "aws_ecs_service" "ecs-service" {
  name            = "ecs"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.ecs-service.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets = var.private_subnet_ids
    security_groups = [var.ecs_tasks_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "ecs"
    container_port   = 80
  }
}
resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/ecs-service"
}