variable "app_name" {
  description = "Name of the application"
  default     = "latrobe"
}

variable "env_name" {
  description = "Name of the environment"
  default     = "stg"
}

variable "cost_center" {
  description = "Tag used to identify the infra cost"
  default     = "Balaji-CD"
}
variable "az_count" {
  description = "Number of Availability Zones"
  default = 2
}
variable "vpc_cidr" {
  description = "IPV4 CIDR Block for the main VPC"
  default     = "10.7.0.0/16"
}

variable "main_domain_name" {
  description = "Main demo domain name for practice"
  default     = "crystaldelta.ai"
}
variable "frontend_domain_name" {
  description = "frontend domain url"
  default = "latrobe.crystaldelta.ai"
}
variable "alb_domain_name" {
  description = "ALB Domain"
  default = "api.latrobe.crystaldelta.ai"
}