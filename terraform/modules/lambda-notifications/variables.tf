variable "function_name" {
  description = "Base name for Lambda functions"
  type        = string
}

variable "users_table_name" {
  description = "DynamoDB users table name"
  type        = string
}

variable "users_table_arn" {
  description = "DynamoDB users table ARN"
  type        = string
}

variable "subscriptions_table_name" {
  description = "DynamoDB subscriptions table name"
  type        = string
}

variable "subscriptions_table_arn" {
  description = "DynamoDB subscriptions table ARN"
  type        = string
}

variable "notifications_table_name" {
  description = "DynamoDB notifications table name"
  type        = string
}

variable "notifications_table_arn" {
  description = "DynamoDB notifications table ARN"
  type        = string
}

variable "notification_history_table_name" {
  description = "DynamoDB notification history table name"
  type        = string
}

variable "notification_history_table_arn" {
  description = "DynamoDB notification history table ARN"
  type        = string
}

variable "stripe_keys_arn" {
  description = "Secrets Manager ARN for Stripe keys"
  type        = string
}

variable "jwt_secret_arn" {
  description = "Secrets Manager ARN for JWT secret"
  type        = string
}

variable "email_topic_arn" {
  description = "SNS email topic ARN"
  type        = string
}

variable "sms_topic_arn" {
  description = "SNS SMS topic ARN"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN for data storage"
  type        = string
}

variable "notification_service_image_uri" {
  description = "ECR image URI for notification service"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for Lambda functions"
  type        = map(string)
  default     = {}
}

variable "schedule_expression" {
  description = "CloudWatch Events schedule expression"
  type        = string
  default     = "rate(5 minutes)"
}

variable "frontend_url" {
  description = "Frontend URL for Stripe checkout redirects"
  type        = string
}