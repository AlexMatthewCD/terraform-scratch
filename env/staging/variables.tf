variable "app_name" {
  description = "Name of the application"
  default     = "scratch-tf"
}

variable "env_name" {
  description = "Name of the environment"
  default     = "stg"
}

variable "vpc_cidr" {
  description = "IPV4 CIDR Block for the VPC"
  default     = "20.7.0.0/20"
}