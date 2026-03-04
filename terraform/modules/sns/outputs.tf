output "email_topic_arn" {
  value = aws_sns_topic.email_notifications.arn
}

output "email_topic_name" {
  value = aws_sns_topic.email_notifications.name
}

output "sms_topic_arn" {
  value = aws_sns_topic.sms_notifications.arn
}

output "sms_topic_name" {
  value = aws_sns_topic.sms_notifications.name
}

output "sns_delivery_role_arn" {
  value = aws_iam_role.sns_delivery_role.arn
}

output "sns_log_group_name" {
  value = aws_cloudwatch_log_group.sns_delivery_logs.name
}