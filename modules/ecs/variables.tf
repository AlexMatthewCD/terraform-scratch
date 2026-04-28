variable "app_name" {
  description = "Name of the Application"
}
variable "env_name" {
  description = "Name of the Application Environment"
}
variable "cost_center" {
  description = "Tag used to identify the infra cost"
}
variable "ecr" {
  description = "ECR repo"
}

variable "private_subnet" {
  description = "Private subnets for docker containers"
}

variable "demo_sg_id" {
  description = "id of demo security group that give public traffic through  internet gateway"
}