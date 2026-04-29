output "vpc_id" {
  value = aws_vpc.main.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.gw.id
}

output "private_subnet" {
  value = aws_subnet.private
}
output "public_subnet" {
  value = aws_subnet.public
}

output "private_route_table_id" {
  value = aws_route_table.private_route.id
}
# output "db_subnet" {
#   value = aws_subnet.db
# }