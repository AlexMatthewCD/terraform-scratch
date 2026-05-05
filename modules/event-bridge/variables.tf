variable "app_name" {
  description = "Name of the Application"
}
variable "env_name" {
  description = "Name of the Application Environment"
}
variable "cost_center" {
  description = "Tag used to identify the infra cost"
}
variable "lambda_function_arn" {
  description = "ARN of the Lambda function to trigger"
}
variable "lambda_function_name" {
  description = "Name of the Lambda function for permission"
}
