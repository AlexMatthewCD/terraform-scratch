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

variable "principal_accounts" {
  description = "principal account to have all KMS actions"
  default     = "PROD-ACCOUNT-ID"
}
variable "kms_role" {
  description = "KMS Role"
}

variable "codepipeline_role" {
  description = "codepipeline Role"
}

variable "codebuild_role" {
  description = "codebuild Role"
}