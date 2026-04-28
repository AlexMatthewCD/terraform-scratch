variable "app_name" {
  description = "Name of the Application"
}
variable "env_name" {
  description = "Name of the Application Environment"
}
variable "cost_center" {
  description = "Tag used to identify the infra cost"
}
variable "ec2_sg_id" {
  description = "EC2 Security group ID"
}
variable "private_subnet_id" {
  description = "Private Subnet ID for EC2 instances"
}
variable "public_subnet_id" {
  description = "Public Subnet ID for Bastion host"
}
variable "bastion_sg_id" {
  description = "Bastion Security group ID"
}