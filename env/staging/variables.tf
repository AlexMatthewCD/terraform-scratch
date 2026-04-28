variable "app_name" {
  description = "Name of the application"
  default     = "wikiJs"
}

variable "env_name" {
  description = "Name of the environment"
  default     = "stg"
}

variable "cost_center" {
  description = "Tag used to identify the infra cost"
  default     = "DevOps-CD"
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
  default     = "crystaldelta.net"
}
