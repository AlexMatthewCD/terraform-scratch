resource "aws_cloudwatch_event_rule" "start_schedule" {
  name                = "${var.app_name}-${var.env_name}-ec2-start"
  description         = "Trigger Lambda to start EC2 instances in the morning"
  schedule_expression = "cron(58 3 ? * * *)"

  tags = {
    Name        = "${var.app_name}-ec2-start-schedule-rule"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_cloudwatch_event_rule" "stop_schedule" {
  name                = "${var.app_name}-${var.env_name}-ec2-stop"
  description         = "Trigger Lambda to stop EC2 instances at night"
  schedule_expression = "cron(59 3 ? * * *)"

  tags = {
    Name        = "${var.app_name}-ec2-stop-schedule-rule"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

resource "aws_cloudwatch_event_target" "lambda_start" {
  rule      = aws_cloudwatch_event_rule.start_schedule.name
  arn       = var.lambda_function_arn
  input     = jsonencode({"action": "start"})
}

resource "aws_cloudwatch_event_target" "lambda_stop" {
  rule      = aws_cloudwatch_event_rule.stop_schedule.name
  arn       = var.lambda_function_arn
  input     = jsonencode({"action": "stop"})
}

resource "aws_lambda_permission" "allow_eventbridge_start" {
  statement_id  = "AllowEventBridgeStart"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_schedule.arn
}

resource "aws_lambda_permission" "allow_eventbridge_stop" {
  statement_id  = "AllowEventBridgeStop"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_schedule.arn
}