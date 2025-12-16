output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.overland_data.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.overland_data.arn
}

output "bucket_url" {
  description = "URL of the S3 bucket"
  value       = "https://${aws_s3_bucket.overland_data.bucket}.s3.amazonaws.com"
}

output "frontend_bucket_name" {
  description = "Name of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.bucket
}

output "frontend_website_endpoint" {
  description = "Website endpoint of the frontend S3 bucket"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}