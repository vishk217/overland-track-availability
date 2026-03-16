resource "aws_sns_topic" "rate_limit_alerts" {
  name = "overland-rate-limit-alerts"
}

resource "aws_cloudwatch_log_metric_filter" "notification_errors" {
  name           = "overland-notification-errors"
  log_group_name = var.lambda_log_group_name
  pattern        = "ERROR"

  metric_transformation {
    name      = "NotificationErrors"
    namespace = "Overland/Notifications"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "notification_error_alarm" {
  alarm_name          = "overland-notification-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "NotificationErrors"
  namespace           = "Overland/Notifications"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors notification service errors"
  alarm_actions       = [aws_sns_topic.rate_limit_alerts.arn]
}
