resource "aws_lambda_function" "auth_lambda" {
  function_name = "${var.function_name}-auth"
  role         = aws_iam_role.lambda_role.arn
  
  package_type = "Image"
  image_uri    = var.notification_service_image_uri
  timeout      = 30
  
  image_config {
    command = ["auth_lambda.lambda_handler"]
  }
  
  environment {
    variables = {
      USERS_TABLE = var.users_table_name
      APP_SECRETS_ARN = var.app_secrets_arn
    }
  }
}

resource "aws_lambda_function" "payment_lambda" {
  function_name = "${var.function_name}-payment"
  role         = aws_iam_role.lambda_role.arn
  
  package_type = "Image"
  image_uri    = var.notification_service_image_uri
  timeout      = 30
  
  image_config {
    command = ["payment_lambda.lambda_handler"]
  }
  
  environment {
    variables = {
      USERS_TABLE = var.users_table_name
      SUBSCRIPTIONS_TABLE = var.subscriptions_table_name
      APP_SECRETS_ARN = var.app_secrets_arn
      FRONTEND_URL = var.frontend_url
    }
  }
}

resource "aws_lambda_function" "notifications_lambda" {
  function_name = "${var.function_name}-notifications"
  role         = aws_iam_role.lambda_role.arn
  
  package_type = "Image"
  image_uri    = var.notification_service_image_uri
  timeout      = 30
  
  image_config {
    command = ["notifications_lambda.lambda_handler"]
  }
  
  environment {
    variables = {
      NOTIFICATIONS_TABLE = var.notifications_table_name
      APP_SECRETS_ARN = var.app_secrets_arn
    }
  }
}

resource "aws_lambda_function" "notification_service" {
  function_name = "${var.function_name}-notification-service"
  role         = aws_iam_role.lambda_role.arn
  
  package_type = "Image"
  image_uri    = var.notification_service_image_uri
  timeout      = 60
  memory_size  = 2048
  
  image_config {
    command = ["notification_service.lambda_handler"]
  }
  
  environment {
    variables = merge(var.environment_variables, {
      NOTIFICATIONS_TABLE = var.notifications_table_name
      NOTIFICATION_HISTORY_TABLE = var.notification_history_table_name
      SES_SENDER_EMAIL = var.ses_sender_email
    })
  }
}



resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.function_name}-policy"
  role = aws_iam_role.lambda_role.id

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
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          var.users_table_arn,
          "${var.users_table_arn}/index/*",
          var.subscriptions_table_arn,
          var.notifications_table_arn,
          var.notification_history_table_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          var.app_secrets_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${var.s3_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_cloudwatch_event_rule" "notification_schedule" {
  name                = "${var.function_name}-notification-schedule"
  description         = "Trigger notification service"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "notification_target" {
  rule      = aws_cloudwatch_event_rule.notification_schedule.name
  target_id = "NotificationServiceTarget"
  arn       = aws_lambda_function.notification_service.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notification_service.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.notification_schedule.arn
}