terraform {
  required_version = "~> 1.14.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.40.0"
    }
  }
  backend "s3" {
    bucket       = "wikijs-stg-tfstate"
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


# resource "aws_s3_bucket" "tfstate" {
#   bucket   = "wikijs-${var.env_name}-tfstate"
#   tags = {
#     Name        = "${var.app_name}-tfstate"
#     Application = var.app_name
#     Environment = var.env_name
#     CostCenter  = var.cost_center
#   }
#   force_destroy = true
# }

# resource "aws_s3_bucket_versioning" "version-tfstate" {
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
  az_count = var.az_count
}

module "security" {
  source      = "../../modules/security"
  app_name    = var.app_name
  env_name    = var.env_name
  vpc_cidr    = var.vpc_cidr
  cost_center = var.cost_center
  vpc_id      = module.vpc.vpc_id
}

module "acm" {
  source      = "../../modules/acm"
  app_name    = var.app_name
  env_name    = var.env_name
  cost_center = var.cost_center
  main_domain_name = var.main_domain_name
}

// used when learning ALB
module "alb" {
  source        = "../../modules/alb"
  app_name      = var.app_name
  env_name      = var.env_name
  cost_center   = var.cost_center
  public_subnet = module.vpc.public_subnet
  vpc_id        = module.vpc.vpc_id
  vpc_cidr      = var.vpc_cidr
  certificate_arn = module.acm.certificate_arn
  main_domain_name = var.main_domain_name
  alb_sg_id = module.security.alb_sg_id
}

module "ec2" {
  source = "../../modules/ec2"
  app_name = var.app_name
  env_name = var.env_name
  cost_center = var.cost_center
  ec2_sg_id = module.security.ec2_sg_id
  bastion_sg_id = module.security.bastion_sg_id
  public_subnet_id = module.vpc.public_subnet[0].id
  private_subnet_id = module.vpc.private_subnet[0].id
}

# # module "cloudfront" {
# #   providers = {
# #     aws.infra = aws.infra
# #     aws.dns = aws.dns
# #   }
# #   source      = "../../modules/cloudfront"
# #   app_name    = var.app_name
# #   env_name    = var.env_name
# #   cost_center = var.cost_center
# #   main_domain_name = var.main_domain_name
# #   certificate = module.acm.certificate
# #   website_bucket = module.s3.website_bucket
# # }

# # module "s3" {
# #   providers = {
# #     aws.infra = aws.infra
# #   }
# #   source      = "../../modules/s3"
# #   app_name    = var.app_name
# #   env_name    = var.env_name
# #   cost_center = var.cost_center
# #   s3_distribution = module.cloudfront.s3_distribution
# # }