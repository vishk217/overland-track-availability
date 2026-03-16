output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (HTTPS URL)"
  value       = "https://${module.cloudfront.cloudfront_domain_name}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.cloudfront_distribution_id
}

output "frontend_bucket_name" {
  description = "Frontend S3 bucket name"
  value       = module.s3.frontend_bucket_name
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = module.api_gateway.api_gateway_url
}

output "ecr_repository_url" {
  description = "ECR repository URL for pushing Docker images"
  value       = module.ecr.repository_url
}

output "app_secrets_arn" {
  description = "Secrets Manager ARN for application secrets"
  value       = module.secrets.app_secrets_arn
  sensitive   = true
}

output "data_bucket_name" {
  description = "S3 bucket name for data storage"
  value       = module.s3.bucket_name
}

output "ses_verification_token" {
  description = "SES domain verification token"
  value       = module.ses.verification_token
}
