variable "app_name" {
  description = "Name of the application"
  default     = "alex-scratch-tf"
}

variable "env_name" {
  description = "Name of the environment"
  default     = "stg"
}

variable "cost_center" {
  description = "Tag used to identify the infra cost"
  default     = "Alex-CD"
}

variable "vpc_cidr" {
  description = "IPV4 CIDR Block for the main VPC"
  default     = "7.7.0.0/20"
}

variable "domain_name" {
  description = "Main demo domain name for practice"
  default     = "crystaldelta.net"
}
