terraform {
  required_version = "~> 1.14.9"
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
  profile = "cd-sandbox:SandboxDeveloperAccess"
}

# provider "aws" {
#   region  = "ap-south-1"
#   profile = "aws-cd-edtech-nonprod:EdtechNonprodDeveloperAccess"
#   alias   = "dns"
# }

# provider "aws" {
#   region  = "us-east-1"
#   profile = "cd-sandbox:SandboxDeveloperAccess"
#   alias   = "east"
# }

# module "iam" {
#   source      = "../../modules/iam"
#   app_name    = var.app_name
#   env_name    = var.env_name
#   cost_center = var.cost_center
# }

module "ecr" {
  source      = "../../modules/ecr"
  app_name    = var.app_name
  env_name    = var.env_name
  cost_center = var.cost_center
}

module "ecs" {
  source      = "../../modules/ecs"
  app_name    = var.app_name
  env_name    = var.env_name
  cost_center = var.cost_center
  ecr         = module.ecr.connect_ecr
  private_subnet = module.vpc.public_subnet
  demo_sg_id    = module.security.demo_sg_id
}

# resource "aws_s3_bucket" "tfstate" {
#   provider = aws.infra
#   bucket   = "${var.app_name}-${var.env_name}-tfstate"
#   tags = {
#     Name        = "${var.app_name}-tfstate"
#     Application = var.app_name
#     Environment = var.env_name
#     CostCenter  = var.cost_center
#   }
#   force_destroy = true
# }

# resource "aws_s3_bucket_versioning" "version-tfstate" {
#   provider = aws.infra
#   bucket   = aws_s3_bucket.tfstate.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }



module "vpc" {
  source      = "../../modules/vpc"
  app_name    = var.app_name
  env_name    = var.env_name
  vpc_cidr    = var.vpc_cidr
  cost_center = var.cost_center
}

module "security" {
  source      = "../../modules/security"
  app_name    = var.app_name
  env_name    = var.env_name
  vpc_cidr    = var.vpc_cidr
  cost_center = var.cost_center
  vpc_id      = module.vpc.vpc_id
}

# module "acm" {
#   providers = {
#     aws.dns   = aws.dns
#     aws.east = aws.east
#   }
#   source      = "../../modules/acm"
#   app_name    = var.app_name
#   env_name    = var.env_name
#   cost_center = var.cost_center
#   domain_name = var.domain_name
#   # demo_alb    = module.alb.demo_alb
# }

// used when learning ALB
# module "alb" {
#   providers = {
#     aws.infra = aws.infra
#   }
#   source        = "../../modules/alb"
#   app_name      = var.app_name
#   env_name      = var.env_name
#   cost_center   = var.cost_center
#   public_subnet = module.vpc.public_subnet
#   vpc_id        = module.vpc.vpc_id
#   vpc_cidr      = var.vpc_cidr
#   demo_sg_id    = module.security.demo_sg_id
# }

# module "cloudfront" {
#   providers = {
#     aws.infra = aws.infra
#     aws.dns = aws.dns
#   }
#   source      = "../../modules/cloudfront"
#   app_name    = var.app_name
#   env_name    = var.env_name
#   cost_center = var.cost_center
#   domain_name = var.domain_name
#   certificate = module.acm.certificate
#   website_bucket = module.s3.website_bucket
# }

# module "s3" {
#   providers = {
#     aws.infra = aws.infra
#   }
#   source      = "../../modules/s3"
#   app_name    = var.app_name
#   env_name    = var.env_name
#   cost_center = var.cost_center
#   s3_distribution = module.cloudfront.s3_distribution
# }