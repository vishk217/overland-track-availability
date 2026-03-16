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
  description = "Add this TXT record in Namecheap: Host=_amazonses, Value=this token"
  value       = module.ses.verification_token
}

output "ses_dkim_tokens" {
  description = "Add these CNAME records in Namecheap for DKIM"
  value = [for token in module.ses.dkim_tokens : {
    host  = "${token}._domainkey"
    value = "${token}.dkim.amazonses.com"
  }]
}

output "ses_mail_from_records" {
  description = "Add these records in Namecheap for MAIL FROM domain"
  value = {
    mx_record  = { host = "mail", value = "feedback-smtp.ap-southeast-2.amazonses.com", priority = 10 }
    spf_record = { host = "mail", type = "TXT", value = "v=spf1 include:amazonses.com ~all" }
  }
}
