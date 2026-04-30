output "static_bucket_arn" {
  value = aws_s3_bucket.latrobe_website.arn
}
output "static_bucket_name" {
  value = aws_s3_bucket.latrobe_website.id
}
output "static_bucket_domain" {
  value = aws_s3_bucket.latrobe_website.bucket_regional_domain_name
}