output "certificate_arn" {
  value = aws_acm_certificate.cf_certificate.arn
}
output "alb_certificate_arn" {
  value = aws_acm_certificate.alb_cert.arn
}