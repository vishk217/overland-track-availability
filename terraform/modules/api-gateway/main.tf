resource "aws_api_gateway_rest_api" "overland_api" {
  name        = "overland-track-api"
  description = "API for Overland Track notification service"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "auth" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  parent_id   = aws_api_gateway_rest_api.overland_api.root_resource_id
  path_part   = "auth"
}

resource "aws_api_gateway_resource" "auth_register" {
  rest_api_id = aws_api_gateway_resource.auth.rest_api_id
  parent_id   = aws_api_gateway_resource.auth.id
  path_part   = "register"
}

resource "aws_api_gateway_resource" "payment" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  parent_id   = aws_api_gateway_rest_api.overland_api.root_resource_id
  path_part   = "payment"
}

resource "aws_api_gateway_resource" "payment_session" {
  rest_api_id = aws_api_gateway_resource.payment.rest_api_id
  parent_id   = aws_api_gateway_resource.payment.id
  path_part   = "session"
}

resource "aws_api_gateway_resource" "payment_status" {
  rest_api_id = aws_api_gateway_resource.payment.rest_api_id
  parent_id   = aws_api_gateway_resource.payment.id
  path_part   = "status"
}

resource "aws_api_gateway_resource" "payment_events" {
  rest_api_id = aws_api_gateway_resource.payment.rest_api_id
  parent_id   = aws_api_gateway_resource.payment.id
  path_part   = "events"
}

resource "aws_api_gateway_resource" "notifications" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  parent_id   = aws_api_gateway_rest_api.overland_api.root_resource_id
  path_part   = "notifications"
}

resource "aws_api_gateway_resource" "notifications_id" {
  rest_api_id = aws_api_gateway_resource.notifications.rest_api_id
  parent_id   = aws_api_gateway_resource.notifications.id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "auth_post" {
  rest_api_id   = aws_api_gateway_rest_api.overland_api.id
  resource_id   = aws_api_gateway_resource.auth.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "auth_register_post" {
  rest_api_id   = aws_api_gateway_rest_api.overland_api.id
  resource_id   = aws_api_gateway_resource.auth_register.id
  http_method   = "POST"
  authorization = "NONE"
}

# CORS OPTIONS methods
resource "aws_api_gateway_method" "auth_options" {
  rest_api_id   = aws_api_gateway_rest_api.overland_api.id
  resource_id   = aws_api_gateway_resource.auth.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "auth_register_options" {
  rest_api_id   = aws_api_gateway_rest_api.overland_api.id
  resource_id   = aws_api_gateway_resource.auth_register.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "payment_session_options" {
  rest_api_id   = aws_api_gateway_rest_api.overland_api.id
  resource_id   = aws_api_gateway_resource.payment_session.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "payment_status_options" {
  rest_api_id   = aws_api_gateway_rest_api.overland_api.id
  resource_id   = aws_api_gateway_resource.payment_status.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "payment_events_options" {
  rest_api_id   = aws_api_gateway_rest_api.overland_api.id
  resource_id   = aws_api_gateway_resource.payment_events.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "notifications_options" {
  rest_api_id   = aws_api_gateway_rest_api.overland_api.id
  resource_id   = aws_api_gateway_resource.notifications.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "payment_session_post" {
  rest_api_id   = aws_api_gateway_rest_api.overland_api.id
  resource_id   = aws_api_gateway_resource.payment_session.id
  http_method   = "POST"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_method" "payment_status_get" {
  rest_api_id   = aws_api_gateway_rest_api.overland_api.id
  resource_id   = aws_api_gateway_resource.payment_status.id
  http_method   = "GET"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_method" "payment_events_post" {
  rest_api_id   = aws_api_gateway_rest_api.overland_api.id
  resource_id   = aws_api_gateway_resource.payment_events.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "notifications_get" {
  rest_api_id   = aws_api_gateway_rest_api.overland_api.id
  resource_id   = aws_api_gateway_resource.notifications.id
  http_method   = "GET"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_method" "notifications_put" {
  rest_api_id   = aws_api_gateway_rest_api.overland_api.id
  resource_id   = aws_api_gateway_resource.notifications.id
  http_method   = "PUT"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_method" "notifications_delete" {
  rest_api_id   = aws_api_gateway_rest_api.overland_api.id
  resource_id   = aws_api_gateway_resource.notifications_id.id
  http_method   = "DELETE"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_method" "notifications_id_options" {
  rest_api_id   = aws_api_gateway_rest_api.overland_api.id
  resource_id   = aws_api_gateway_resource.notifications_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_deployment" "overland_api_deployment" {
  depends_on = [
    aws_api_gateway_method.auth_post,
    aws_api_gateway_method.auth_register_post,
    aws_api_gateway_method.payment_session_post,
    aws_api_gateway_method.payment_status_get,
    aws_api_gateway_method.payment_events_post,
    aws_api_gateway_method.notifications_get,
    aws_api_gateway_method.notifications_put,
    aws_api_gateway_method.notifications_delete,
    aws_api_gateway_integration.auth_integration,
    aws_api_gateway_integration.auth_register_integration,
    aws_api_gateway_integration.payment_session_integration,
    aws_api_gateway_integration.payment_status_integration,
    aws_api_gateway_integration.payment_events_integration,
    aws_api_gateway_integration.notifications_get_integration,
    aws_api_gateway_integration.notifications_put_integration,
    aws_api_gateway_integration.notifications_delete_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.auth.id,
      aws_api_gateway_resource.auth_register.id,
      aws_api_gateway_resource.payment.id,
      aws_api_gateway_resource.payment_session.id,
      aws_api_gateway_resource.payment_status.id,
      aws_api_gateway_resource.payment_events.id,
      aws_api_gateway_resource.notifications.id,
      aws_api_gateway_resource.notifications_id.id,
      aws_api_gateway_method.auth_post.id,
      aws_api_gateway_method.auth_register_post.id,
      aws_api_gateway_method.payment_session_post.id,
      aws_api_gateway_method.payment_status_get.id,
      aws_api_gateway_method.payment_events_post.id,
      aws_api_gateway_method.notifications_get.id,
      aws_api_gateway_method.notifications_put.id,
      aws_api_gateway_method.notifications_delete.id,
      aws_api_gateway_integration.auth_integration.id,
      aws_api_gateway_integration.auth_register_integration.id,
      aws_api_gateway_integration.payment_session_integration.id,
      aws_api_gateway_integration.payment_status_integration.id,
      aws_api_gateway_integration.payment_events_integration.id,
      aws_api_gateway_integration.notifications_get_integration.id,
      aws_api_gateway_integration.notifications_put_integration.id,
      aws_api_gateway_integration.notifications_delete_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "overland_api_stage" {
  deployment_id = aws_api_gateway_deployment.overland_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.overland_api.id
  stage_name    = "prod"
}