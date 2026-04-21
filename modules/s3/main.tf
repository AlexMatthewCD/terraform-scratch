terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.infra]
    }
  }
}

resource "aws_s3_bucket" "demo_website" {
    provider = aws.infra
  bucket = "${var.app_name}-${var.env_name}-demo-web"

  tags = {
    Name        = "${var.app_name}-demo-web"
    Environment = var.env_name
    Application = var.app_name
    CostCenter  = var.cost_center
  }
}

data "aws_iam_policy_document" "origin_bucket_policy" {
    provider = aws.infra
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.demo_website.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [var.s3_distribution.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "demo_website" {
  provider = aws.infra
  bucket = aws_s3_bucket.demo_website.bucket
  policy = data.aws_iam_policy_document.origin_bucket_policy.json
}