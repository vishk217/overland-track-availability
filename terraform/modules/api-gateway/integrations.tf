resource "aws_api_gateway_integration" "auth_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.auth.id
  http_method = aws_api_gateway_method.auth_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.auth_lambda_invoke_arn
}

resource "aws_api_gateway_integration" "payment_session_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.payment_session.id
  http_method = aws_api_gateway_method.payment_session_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.payment_lambda_invoke_arn
}

resource "aws_api_gateway_integration" "payment_status_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.payment_status.id
  http_method = aws_api_gateway_method.payment_status_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.payment_lambda_invoke_arn
}

resource "aws_api_gateway_integration" "payment_events_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.payment_events.id
  http_method = aws_api_gateway_method.payment_events_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.payment_lambda_invoke_arn
}

resource "aws_api_gateway_integration" "notifications_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.notifications.id
  http_method = aws_api_gateway_method.notifications_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.notifications_lambda_invoke_arn
}

resource "aws_api_gateway_integration" "notifications_put_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.notifications.id
  http_method = aws_api_gateway_method.notifications_put.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = var.notifications_lambda_invoke_arn
}

resource "aws_lambda_permission" "auth_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.auth_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.overland_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "payment_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.payment_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.overland_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "notifications_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.notifications_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.overland_api.execution_arn}/*/*"
}