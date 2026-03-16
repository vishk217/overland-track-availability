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

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "secrets" {
  source = "./modules/secrets"
}

module "lambda_notifications" {
  source = "./modules/lambda-notifications"
  function_name = var.lambda_function_name
  users_table_name = module.dynamodb.users_table_name
  users_table_arn = module.dynamodb.users_table_arn
  subscriptions_table_name = module.dynamodb.subscriptions_table_name
  subscriptions_table_arn = module.dynamodb.subscriptions_table_arn
  notifications_table_name = module.dynamodb.notifications_table_name
  notifications_table_arn = module.dynamodb.notifications_table_arn
  notification_history_table_name = module.dynamodb.notification_history_table_name
  notification_history_table_arn = module.dynamodb.notification_history_table_arn
  app_secrets_arn = module.secrets.app_secrets_arn
  ses_sender_email = var.ses_sender_email
  s3_bucket_arn = module.s3.bucket_arn
  notification_service_image_uri = "${module.ecr.repository_url}:${var.image_tag}"
  frontend_url = "https://${var.domain_name[0]}"
  environment_variables = {
    S3_BUCKET = module.s3.bucket_name
    TZ = "Australia/Sydney"
  }
}

module "monitoring" {
  source = "./modules/monitoring"
  lambda_log_group_name = "/aws/lambda/${var.lambda_function_name}-notification-service"
}

module "ses" {
  source      = "./modules/ses"
  domain_name = var.domain_name[0]
  aws_region  = var.aws_region
}

module "api_gateway" {
  source = "./modules/api-gateway"
  auth_lambda_invoke_arn = module.lambda_notifications.auth_lambda_arn
  payment_lambda_invoke_arn = module.lambda_notifications.payment_lambda_arn
  notifications_lambda_invoke_arn = module.lambda_notifications.notifications_lambda_arn
  auth_lambda_function_name = "${var.lambda_function_name}-auth"
  payment_lambda_function_name = "${var.lambda_function_name}-payment"
  notifications_lambda_function_name = "${var.lambda_function_name}-notifications"
}