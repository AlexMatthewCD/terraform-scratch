variable "app_name" {
  description = "Name of the Application"
}
variable "env_name" {
  description = "Name of the Application Environment"
}
variable "cost_center" {
  description = "Tag used to identify the infra cost"
}


variable "private_subnet" {
  description = "Private subnets for docker containers"
}

variable "demo_sg_id" {
  description = "id of demo security group that give public traffic through  internet gateway"
}

variable "vpc_id" {
  description = "ID value of the VPC"
}

variable "private_route_table_id" {
  description = "ID of the private route table so the S3 Gateway endpoint can route ECR layer pulls"
}
