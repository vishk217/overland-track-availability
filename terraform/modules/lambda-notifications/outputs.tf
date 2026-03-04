output "auth_lambda_arn" {
  value = aws_lambda_function.auth_lambda.arn
}

output "payment_lambda_arn" {
  value = aws_lambda_function.payment_lambda.arn
}

output "notifications_lambda_arn" {
  value = aws_lambda_function.notifications_lambda.arn
}

output "notification_service_arn" {
  value = aws_lambda_function.notification_service.arn
}