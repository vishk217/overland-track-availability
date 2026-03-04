variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for data"
  type        = string
  default     = "overland-track-data"
}

variable "frontend_bucket_name" {
  description = "Name of the frontend S3 bucket"
  type        = string
  default     = "overland-track-frontend"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "overland-track-automation"
}

variable "image_tag" {
  description = "Docker image tag for Lambda function"
  type        = string
  default     = "latest"
}

variable "domain_name" {
  description = "Custom domain names for CloudFront distribution"
  type        = list(string)
  default     = ["overlandtrackavailability.com", "www.overlandtrackavailability.com"]
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the custom domain"
  type        = string
  default     = "arn:aws:acm:us-east-1:842556421867:certificate/de4ba38a-86fe-4032-b187-a927532e6e51"
}

variable "stripe_publishable_key" {
  description = "Stripe publishable key"
  type        = string
  sensitive   = true
}

variable "stripe_secret_key" {
  description = "Stripe secret key"
  type        = string
  sensitive   = true
}

variable "stripe_webhook_secret" {
  description = "Stripe webhook secret"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT signing secret"
  type        = string
  sensitive   = true
}
