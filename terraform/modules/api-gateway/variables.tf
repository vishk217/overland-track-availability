variable "auth_lambda_invoke_arn" {
  description = "Auth Lambda invoke ARN"
  type        = string
}

variable "payment_lambda_invoke_arn" {
  description = "Payment Lambda invoke ARN"
  type        = string
}

variable "notifications_lambda_invoke_arn" {
  description = "Notifications Lambda invoke ARN"
  type        = string
}

variable "auth_lambda_function_name" {
  description = "Auth Lambda function name"
  type        = string
}

variable "payment_lambda_function_name" {
  description = "Payment Lambda function name"
  type        = string
}

variable "notifications_lambda_function_name" {
  description = "Notifications Lambda function name"
  type        = string
}