variable "vpc_cidr" {
  description = "IPV4 CIDR Block for the main VPC"
}
variable "app_name" {
  description = "Name of the Application"
}
variable "env_name" {
  description = "Name of the Application Environment"
}
variable "cost_center" {
  description = "Tag used to identify the infra cost"
}
variable "vpc_id" {
  description = "ID value of the VPC"
}
variable "public_subnet" {
  description = "Public subnets of the VPC that gets internet traffic"
}

variable "alb_sg_id" {
  description = "id of ALB security group that give public traffic through  internet gateway"
}
variable "certificate_arn" {
  description = "ARN of the ACM certificate"
}
variable "main_domain_name" {
  description = "Name of the main domain"
}
variable "alb_domain_name" {
  description = "ALB Domain"
}