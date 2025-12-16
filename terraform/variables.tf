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
