variable "frontend_bucket_domain_name" {
  description = "Frontend S3 bucket domain name"
  type        = string
}

variable "frontend_bucket_name" {
  description = "Name of the frontend S3 bucket"
  type        = string
}

variable "domain_name" {
  description = "Custom domain name for CloudFront distribution"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the custom domain"
  type        = string
}