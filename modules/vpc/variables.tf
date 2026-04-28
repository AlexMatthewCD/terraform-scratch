variable "vpc_cidr" {
  description = "IPV4 CIDR Block for the main VPC"
}
variable "app_name" {
  description = "Name of the Application"
}
variable "env_name" {
  description = "Name of the Application Environment"
}
variable "az_count" {
  description = "Number of Availability Zones"
}
variable "cost_center" {
  description = "Tag used to identify the infra cost"
}