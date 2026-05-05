# resource "aws_iam_role" "task_execution_role" {
#   name = "${var.app_name}-${var.env_name}-task-execution-role"

#   tags = {
#     Name        = "${var.app_name}-task-execution-role"
#     Environment = var.env_name
#     Application = var.app_name
#     CostCenter  = var.cost_center
#   }
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = [
#             "ecs-tasks.amazonaws.com"
#           ]
#         }
#       },
#     ]
#   })
# }

// role created for ec2 stoppe rand starter lambda function
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "instance_automatic_schedule_role" {
  statement {
    sid    = "lambdaRuleWithEc2"
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "ec2:Start*",
      "ec2:Stop*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "lambdaRuleWithEventbridge"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role" "lambda_ec2_access" {
  name               = "${var.app_name}-${var.env_name}-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Name        = "${var.app_name}-lambda-execution-role"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_iam_role_policy" "ec2_start_stop_policy" {
  name   = "ec2_start_stop_policy"
  role   = aws_iam_role.lambda_ec2_access.id
  policy = data.aws_iam_policy_document.instance_automatic_schedule_role.json
}