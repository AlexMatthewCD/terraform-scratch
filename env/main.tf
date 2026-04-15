terraform {
  required_version = "~> 1.14.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.40.0"
    }
  }
  backend "s3" {
    bucket       = "scratch-tf-stg-tfstate"
    key          = "terraform.tfstate"
    region       = "ap-south-1"
    profile      = "cd-sandbox"
    encrypt      = false
    use_lockfile = true
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "cd-sandbox"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "${var.app_name}-${var.env_name}-tfstate"
  tags = {
    Name        = "${var.app_name}-tfstate"
    Environment = var.env_name
  }
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "version-tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}
