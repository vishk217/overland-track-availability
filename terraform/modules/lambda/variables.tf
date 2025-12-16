variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 300
}

variable "memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 1024
}

variable "environment_variables" {
  description = "Environment variables for Lambda"
  type        = map(string)
  default     = {}
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket for permissions"
  type        = string
}

variable "schedule_expression" {
  description = "EventBridge schedule expression"
  type        = string
  default     = "rate(6 hours)"
}

variable "image_uri" {
  description = "ECR image URI for container-based Lambda"
  type        = string
  default     = null
}