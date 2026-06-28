resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.api_name}"
  retention_in_days = var.access_log_retention_in_days
}

resource "aws_apigatewayv2_api" "this" {
  name          = var.api_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_headers = var.cors_allow_headers
    allow_methods = var.cors_allow_methods
    allow_origins = var.cors_allow_origins
    max_age       = var.cors_max_age
  }
}

# VPC Link for private integration: gives API Gateway ENIs inside the VPC so it
# can reach the internal NLB without any public exposure. Created only when
# private_integration = true.
resource "aws_apigatewayv2_vpc_link" "this" {
  count = var.private_integration ? 1 : 0

  name               = "${var.name_prefix}-vpclink-01"
  subnet_ids         = var.vpc_link_subnet_ids
  security_group_ids = var.vpc_link_security_group_ids
}

resource "aws_apigatewayv2_integration" "proxy" {
  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"

  # Private (VPC Link -> internal NLB listener) or public (HTTP_PROXY -> URL).
  integration_uri = var.private_integration ? var.nlb_listener_arn : var.upstream_service_url
  connection_type = var.private_integration ? "VPC_LINK" : "INTERNET"
  connection_id   = var.private_integration ? aws_apigatewayv2_vpc_link.this[0].id : null

  timeout_milliseconds   = var.integration_timeout_milliseconds
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_authorizer" "jwt" {
  api_id           = aws_apigatewayv2_api.this.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.name_prefix}-apiauthz-01"

  jwt_configuration {
    audience = [var.oauth_audience]
    issuer   = var.oauth_issuer_url
  }
}

resource "aws_apigatewayv2_route" "root" {
  api_id               = aws_apigatewayv2_api.this.id
  route_key            = "ANY /"
  target               = "integrations/${aws_apigatewayv2_integration.proxy.id}"
  authorization_type   = "JWT"
  authorizer_id        = aws_apigatewayv2_authorizer.jwt.id
  authorization_scopes = [var.oauth_scope]
}

resource "aws_apigatewayv2_route" "proxy" {
  api_id               = aws_apigatewayv2_api.this.id
  route_key            = "ANY /{proxy+}"
  target               = "integrations/${aws_apigatewayv2_integration.proxy.id}"
  authorization_type   = "JWT"
  authorizer_id        = aws_apigatewayv2_authorizer.jwt.id
  authorization_scopes = [var.oauth_scope]
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId        = "$context.requestId"
      ip               = "$context.identity.sourceIp"
      requestTime      = "$context.requestTime"
      httpMethod       = "$context.httpMethod"
      routeKey         = "$context.routeKey"
      status           = "$context.status"
      protocol         = "$context.protocol"
      responseLength   = "$context.responseLength"
      integrationError = "$context.integrationErrorMessage"
    })
  }
}
