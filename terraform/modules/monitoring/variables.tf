variable "lambda_log_group_name" {
  description = "CloudWatch log group name for the notification service Lambda"
  type        = string
}

variable "lambda_log_group_names" {
  description = "All CloudWatch log group names to manage retention for"
  type        = list(string)
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}
