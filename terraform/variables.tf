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
  description = "Custom domain name for CloudFront distribution"
  type        = string
  default     = "overlandtrackavailability.com"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the custom domain"
  type        = string
  default     = "arn:aws:acm:ap-southeast-2:842556421867:certificate/d106e3a3-721f-431b-9412-c3535ca08a17"
}
