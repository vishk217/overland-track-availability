output "users_table_name" {
  value = aws_dynamodb_table.users.name
}

output "users_table_arn" {
  value = aws_dynamodb_table.users.arn
}

output "subscriptions_table_name" {
  value = aws_dynamodb_table.subscriptions.name
}

output "subscriptions_table_arn" {
  value = aws_dynamodb_table.subscriptions.arn
}

output "notifications_table_name" {
  value = aws_dynamodb_table.notifications.name
}

output "notifications_table_arn" {
  value = aws_dynamodb_table.notifications.arn
}

output "notification_history_table_name" {
  value = aws_dynamodb_table.notification_history.name
}

output "notification_history_table_arn" {
  value = aws_dynamodb_table.notification_history.arn
}