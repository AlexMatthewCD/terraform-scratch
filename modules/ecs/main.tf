resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.app_name}-${var.env_name}-cluster"

  tags = {
    Name        = "${var.app_name}-cluster"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

data "aws_iam_role" "ecs_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_ecs_task_definition" "app_task_def" {
  family                   = "${var.app_name}-${var.env_name}-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn = data.aws_iam_role.ecs_execution_role.arn
  container_definitions = templatefile("../../env/staging/taskdefinition/container.json", {
    app_name                = var.app_name
    env_name                = var.env_name
    app_ecr                 = var.ecr
    tag                     = "latest"
    soft_memory_reservation = 512
  })
  tags = {
    Name        = "${var.app_name}-task-definition"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_ecs_service" "api" {
  name            = "${var.app_name}-${var.env_name}-api-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  launch_type     = "FARGATE"
  desired_count   = 0
  task_definition = aws_ecs_task_definition.app_task_def.arn

  network_configuration {
    security_groups = [var.demo_sg_id]
    subnets         = [var.private_subnet[0].id, var.private_subnet[1].id]
  }

  deployment_circuit_breaker {
    enable = false
    rollback = false
  }

  tags = {
    Name        = "${var.app_name}-api-service"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}