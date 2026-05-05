# Package the Lambda function code
data "archive_file" "function_zip" {
  type        = "zip"
  source_file = "${path.module}/../../functions/start_stop_ec2/code.py"
  output_path = "${path.module}/../../functions/start_stop_ec2.zip"
}

# Lambda function
resource "aws_lambda_function" "example" {
  filename      = data.archive_file.function_zip.output_path
  function_name = "${var.app_name}-${var.env_name}-ec2-starter-stopper"
  role          = var.iam_role_arn
  handler       = "code.lambda_handler"
  code_sha256   = data.archive_file.function_zip.output_base64sha256

  runtime = "python3.10"
  timeout = 60

  environment {
    variables = {
      ENVIRONMENT = var.env_name
      LOG_LEVEL   = "info"
    }
  }

  tags = {
    Name        = "${var.app_name}-ec2-starter-stopper"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}