variable "email_topic_name" {
  description = "Name of the email SNS topic"
  type        = string
}

variable "sms_topic_name" {
  description = "Name of the SMS SNS topic"
  type        = string
}

variable "sns_log_group_name" {
  description = "Name of the SNS CloudWatch log group"
  type        = string
}