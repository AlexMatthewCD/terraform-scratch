resource "aws_iam_role" "task_execution_role" {
  name = "${var.app_name}-${var.env_name}-task-execution-role"

  tags = {
    Name        = "${var.app_name}-task-execution-role"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ecs-tasks.amazonaws.com"
          ]
        }
      },
    ]
  })
}