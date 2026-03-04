resource "aws_cloudwatch_metric_alarm" "sns_email_rate_limit" {
  alarm_name          = "overland-sns-email-rate-limit"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "NumberOfMessagesPublished"
  namespace           = "AWS/SNS"
  period              = "300"
  statistic           = "Sum"
  threshold           = "100"
  alarm_description   = "This metric monitors SNS email message rate"
  alarm_actions       = [aws_sns_topic.rate_limit_alerts.arn]

  dimensions = {
    TopicName = var.email_topic_name
  }
}

resource "aws_cloudwatch_metric_alarm" "sns_sms_rate_limit" {
  alarm_name          = "overland-sns-sms-rate-limit"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "NumberOfMessagesPublished"
  namespace           = "AWS/SNS"
  period              = "300"
  statistic           = "Sum"
  threshold           = "50"
  alarm_description   = "This metric monitors SNS SMS message rate"
  alarm_actions       = [aws_sns_topic.rate_limit_alerts.arn]

  dimensions = {
    TopicName = var.sms_topic_name
  }
}

resource "aws_sns_topic" "rate_limit_alerts" {
  name = "overland-rate-limit-alerts"
}

resource "aws_cloudwatch_log_metric_filter" "notification_errors" {
  name           = "overland-notification-errors"
  log_group_name = var.sns_log_group_name
  pattern        = "ERROR"

  metric_transformation {
    name      = "NotificationErrors"
    namespace = "Overland/Notifications"
    value     = "1"
  }
}