terraform {
  required_version = "~> 1.14.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.40.0"
    }
  }
  # backend "s3" {
  #   bucket       = "alex-scratch-tf-stg-tfstate"
  #   key          = "terraform.tfstate"
  #   region       = "ap-south-1"
  #   profile      = "cd-sandbox"
  #   encrypt      = false
  #   use_lockfile = true
  # }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "cd-sandbox"
  alias   = "infra"
}

provider "aws" {
  region  = "ap-south-1"
  profile = "iems"
  alias   = "dns"
}


resource "aws_s3_bucket" "tfstate" {
  provider = aws.infra
  bucket   = "${var.app_name}-${var.env_name}-tfstate"
  tags = {
    Name        = "${var.app_name}-tfstate"
    Application = var.app_name
    Environment = var.env_name
    CostCenter  = var.cost_center
  }
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "version-tfstate" {
  provider = aws.infra
  bucket   = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

module "vpc" {
  providers = {
    aws.infra = aws.infra
  }
  source      = "../../modules/vpc"
  app_name    = var.app_name
  env_name    = var.env_name
  vpc_cidr    = var.vpc_cidr
  cost_center = var.cost_center
}

module "security" {
  providers = {
    aws.infra = aws.infra
  }
  source      = "../../modules/security"
  app_name    = var.app_name
  env_name    = var.env_name
  vpc_cidr    = var.vpc_cidr
  cost_center = var.cost_center
  vpc_id      = module.vpc.vpc_id
}

module "acm" {
  providers = {
    aws.infra = aws.infra
    aws.dns = aws.dns
  }
  source      = "../../modules/acm"
  app_name    = var.app_name
  env_name    = var.env_name
  cost_center = var.cost_center
  domain_name = var.domain_name
}