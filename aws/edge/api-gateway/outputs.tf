output "api_name" {
  value = aws_apigatewayv2_api.this.name
}

output "api_id" {
  value = aws_apigatewayv2_api.this.id
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.this.api_endpoint
}

output "stage_name" {
  value = aws_apigatewayv2_stage.default.name
}

output "access_log_group_name" {
  value = aws_cloudwatch_log_group.api_gateway.name
}
