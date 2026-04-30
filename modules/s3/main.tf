resource "aws_s3_bucket" "latrobe_website" {
  bucket = "${var.app_name}-${var.env_name}-static-bucket"

  tags = {
    Name        = "${var.app_name}-static-bucket"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}
resource "aws_s3_bucket_versioning" "frontend_versioning" {
  bucket = aws_s3_bucket.latrobe_website.id
  versioning_configuration {
    status = "Enabled"
  }
}
#Object ownership for Frontend Static site Bucket
resource "aws_s3_bucket_ownership_controls" "frontend_ownership" {
  bucket = aws_s3_bucket.latrobe_website.id
  rule {
    object_ownership = "ObjectWriter"
  }
}
#Public Access for Frontend Static Bucket
resource "aws_s3_bucket_public_access_block" "frontend_public_access" {
  bucket = aws_s3_bucket.latrobe_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
#ACL for Frontend Static Bucket
resource "aws_s3_bucket_acl" "frontend_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.frontend_ownership]

  bucket = aws_s3_bucket.latrobe_website.id
  acl    = "private"
}
#Website Configuration for Frontend Static Bucket
resource "aws_s3_bucket_website_configuration" "mvr_website" {
  bucket = aws_s3_bucket.latrobe_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}
#CORS configuration for Frontend Static Bucket
resource "aws_s3_bucket_cors_configuration" "mvr_cors" {
  bucket = aws_s3_bucket.latrobe_website.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = []
  }
}

resource "aws_s3_bucket_website_configuration" "static" {
  bucket = aws_s3_bucket.latrobe_website.id
  
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}