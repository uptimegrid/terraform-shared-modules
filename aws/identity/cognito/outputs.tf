output "oauth_issuer_url" {
  value = "https://cognito-idp.${data.aws_region.current.region}.amazonaws.com/${aws_cognito_user_pool.this.id}"
}

output "oauth_audience" {
  value = aws_cognito_user_pool_client.this.id
}

output "oauth_scope" {
  value = aws_cognito_resource_server.this.scope_identifiers[0]
}

output "oauth_token_endpoint" {
  value = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.region}.amazoncognito.com/oauth2/token"
}

output "oauth_client_id" {
  value = aws_cognito_user_pool_client.this.id
}

output "oauth_client_secret" {
  value     = aws_cognito_user_pool_client.this.client_secret
  sensitive = true
}
