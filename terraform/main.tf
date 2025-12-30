terraform {
  backend "s3" {
    bucket  = "overland-track-terraform-state"
    key     = "terraform.tfstate"
    region  = "ap-southeast-2"
    encrypt = true
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3" {
  source                      = "./modules/s3"
  bucket_name                 = var.s3_bucket_name
  frontend_bucket_name        = var.frontend_bucket_name
}

module "cloudfront" {
  source                  = "./modules/cloudfront"
  frontend_bucket_domain_name   = module.s3.frontend_bucket_domain_name
  frontend_bucket_name          = var.frontend_bucket_name
  domain_name                   = var.domain_name
  certificate_arn               = var.certificate_arn
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = "overland-track-lambda"
}

module "lambda" {
  source               = "./modules/lambda"
  function_name        = var.lambda_function_name
  image_uri           = "${module.ecr.repository_url}:${var.image_tag}"
  s3_bucket_arn        = module.s3.bucket_arn
  schedule_expression  = "rate(5 minutes)"
  environment_variables = {
    S3_BUCKET = module.s3.bucket_name
    TZ = "Australia/Sydney"
  }
}