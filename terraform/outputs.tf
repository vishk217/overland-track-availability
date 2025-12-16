output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3.bucket_name
}

output "s3_bucket_url" {
  description = "URL of the S3 bucket"
  value       = module.s3.bucket_url
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda.function_name
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = module.lambda.role_arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "frontend_url" {
  value = "http://${module.s3.frontend_website_endpoint}"
}