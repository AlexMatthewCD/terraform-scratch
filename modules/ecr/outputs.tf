output "connect_ecr" {
  value = aws_ecr_repository.connnect_ecr.repository_url
}