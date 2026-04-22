variable "app_name" {
  description = "Name of the Application"
}
variable "env_name" {
  description = "Name of the Application Environment"
}
variable "cost_center" {
  description = "Tag used to identify the infra cost"
}
variable "s3_distribution" {
  description = "cdn distribution for the s3 static hosting"
}
variable "engine_version" {
  description = "PostgreSQL Engine version"
  default     = "17.7"
}