variable "app_name" {
  description = "Name of the Application"
}
variable "env_name" {
  description = "Name of the Application Environment"
}
variable "cost_center" {
  description = "Tag used to identify the infra cost"
}
variable "main_domain_name" {
  description = "Main demo domain name for practice"
}
variable "frontend_domain_name" {
  description = "Frontend Domain url"
}
variable "s3_static" {
  description = "URL of the S3 Bucket"
}
variable "nv_cf_certificate" {
  description = "Passing certificate to get ARN value"
}