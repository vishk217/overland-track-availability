resource "aws_sns_topic" "email_notifications" {
  name = "overland-email-notifications"
  
  tags = {
    Name = "overland-email-notifications"
  }
}

resource "aws_sns_topic" "sms_notifications" {
  name = "overland-sms-notifications"
  
  tags = {
    Name = "overland-sms-notifications"
  }
}

resource "aws_cloudwatch_log_group" "sns_delivery_logs" {
  name              = "/aws/sns/overland-notifications"
  retention_in_days = 7
}

data "aws_iam_policy_document" "sns_delivery_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sns_delivery_role" {
  name               = "overland-sns-delivery-role"
  assume_role_policy = data.aws_iam_policy_document.sns_delivery_role_policy.json
}

resource "aws_iam_role_policy" "sns_delivery_policy" {
  name = "overland-sns-delivery-policy"
  role = aws_iam_role.sns_delivery_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.sns_delivery_logs.arn}:*"
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "email_delivery_status" {
  topic_arn = aws_sns_topic.email_notifications.arn
  protocol  = "lambda"
  endpoint  = var.notification_lambda_arn
}

resource "aws_sns_topic_subscription" "sms_delivery_status" {
  topic_arn = aws_sns_topic.sms_notifications.arn
  protocol  = "lambda"
  endpoint  = var.notification_lambda_arn
}