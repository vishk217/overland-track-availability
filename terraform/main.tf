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
  source               = "./modules/s3"
  bucket_name          = var.s3_bucket_name
  frontend_bucket_name = var.frontend_bucket_name
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = "overland-track-lambda"
}

module "lambda" {
  source               = "./modules/lambda"
  function_name        = var.lambda_function_name
  image_uri           = "${module.ecr.repository_url}:latest"
  s3_bucket_arn        = module.s3.bucket_arn
  environment_variables = {
    S3_BUCKET = module.s3.bucket_name
  }
}