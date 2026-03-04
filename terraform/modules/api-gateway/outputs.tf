output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.overland_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
}

data "aws_region" "current" {}

output "api_gateway_id" {
  value = aws_api_gateway_rest_api.overland_api.id
}

output "api_gateway_execution_arn" {
  value = aws_api_gateway_rest_api.overland_api.execution_arn
}

output "auth_resource_id" {
  value = aws_api_gateway_resource.auth.id
}

output "payment_resource_id" {
  value = aws_api_gateway_resource.payment.id
}

output "notifications_resource_id" {
  value = aws_api_gateway_resource.notifications.id
}