data "aws_region" "current" {}

resource "aws_api_gateway_integration" "auth_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.auth.id
  http_method = aws_api_gateway_method.auth_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.auth_lambda_invoke_arn}/invocations"
}

resource "aws_api_gateway_integration" "auth_register_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.auth_register.id
  http_method = aws_api_gateway_method.auth_register_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.auth_lambda_invoke_arn}/invocations"
}

# CORS integrations
resource "aws_api_gateway_integration" "auth_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.auth.id
  http_method = aws_api_gateway_method.auth_options.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "auth_register_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.auth_register.id
  http_method = aws_api_gateway_method.auth_register_options.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "payment_session_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.payment_session.id
  http_method = aws_api_gateway_method.payment_session_options.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "payment_status_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.payment_status.id
  http_method = aws_api_gateway_method.payment_status_options.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "payment_events_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.payment_events.id
  http_method = aws_api_gateway_method.payment_events_options.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "notifications_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.notifications.id
  http_method = aws_api_gateway_method.notifications_options.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Method responses for CORS
resource "aws_api_gateway_method_response" "auth_options_200" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.auth.id
  http_method = aws_api_gateway_method.auth_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "auth_register_options_200" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.auth_register.id
  http_method = aws_api_gateway_method.auth_register_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "payment_session_options_200" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.payment_session.id
  http_method = aws_api_gateway_method.payment_session_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "payment_status_options_200" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.payment_status.id
  http_method = aws_api_gateway_method.payment_status_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "payment_events_options_200" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.payment_events.id
  http_method = aws_api_gateway_method.payment_events_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "notifications_options_200" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.notifications.id
  http_method = aws_api_gateway_method.notifications_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Integration responses for CORS
resource "aws_api_gateway_integration_response" "auth_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.auth.id
  http_method = aws_api_gateway_method.auth_options.http_method
  status_code = aws_api_gateway_method_response.auth_options_200.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://overlandtrackavailability.com'"
  }
}

resource "aws_api_gateway_integration_response" "auth_register_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.auth_register.id
  http_method = aws_api_gateway_method.auth_register_options.http_method
  status_code = aws_api_gateway_method_response.auth_register_options_200.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://overlandtrackavailability.com'"
  }
}

resource "aws_api_gateway_integration_response" "payment_session_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.payment_session.id
  http_method = aws_api_gateway_method.payment_session_options.http_method
  status_code = aws_api_gateway_method_response.payment_session_options_200.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://overlandtrackavailability.com'"
  }
}

resource "aws_api_gateway_integration_response" "payment_status_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.payment_status.id
  http_method = aws_api_gateway_method.payment_status_options.http_method
  status_code = aws_api_gateway_method_response.payment_status_options_200.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://overlandtrackavailability.com'"
  }
}

resource "aws_api_gateway_integration_response" "payment_events_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.payment_events.id
  http_method = aws_api_gateway_method.payment_events_options.http_method
  status_code = aws_api_gateway_method_response.payment_events_options_200.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://overlandtrackavailability.com'"
  }
}

resource "aws_api_gateway_integration_response" "notifications_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.notifications.id
  http_method = aws_api_gateway_method.notifications_options.http_method
  status_code = aws_api_gateway_method_response.notifications_options_200.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://overlandtrackavailability.com'"
  }
}

resource "aws_api_gateway_method_response" "notifications_id_options_200" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.notifications_id.id
  http_method = aws_api_gateway_method.notifications_id_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "notifications_id_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.notifications_id.id
  http_method = aws_api_gateway_method.notifications_id_options.http_method
  status_code = aws_api_gateway_method_response.notifications_id_options_200.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://overlandtrackavailability.com'"
  }
}

resource "aws_api_gateway_integration" "payment_session_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.payment_session.id
  http_method = aws_api_gateway_method.payment_session_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.payment_lambda_invoke_arn}/invocations"
}

resource "aws_api_gateway_integration" "payment_status_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.payment_status.id
  http_method = aws_api_gateway_method.payment_status_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.payment_lambda_invoke_arn}/invocations"
}

resource "aws_api_gateway_integration" "payment_events_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.payment_events.id
  http_method = aws_api_gateway_method.payment_events_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.payment_lambda_invoke_arn}/invocations"
}

resource "aws_api_gateway_integration" "notifications_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.notifications.id
  http_method = aws_api_gateway_method.notifications_get.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.notifications_lambda_invoke_arn}/invocations"
}

resource "aws_api_gateway_integration" "notifications_put_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.notifications.id
  http_method = aws_api_gateway_method.notifications_put.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.notifications_lambda_invoke_arn}/invocations"
}

resource "aws_api_gateway_integration" "notifications_delete_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.notifications_id.id
  http_method = aws_api_gateway_method.notifications_delete.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${var.notifications_lambda_invoke_arn}/invocations"
}

resource "aws_api_gateway_integration" "notifications_id_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.overland_api.id
  resource_id = aws_api_gateway_resource.notifications_id.id
  http_method = aws_api_gateway_method.notifications_id_options.http_method
  type        = "MOCK"
  
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
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