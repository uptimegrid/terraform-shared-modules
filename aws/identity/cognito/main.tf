data "aws_region" "current" {}

resource "aws_cognito_user_pool" "this" {
  name                = "${var.name_prefix}-cognito-pool-01"
  deletion_protection = var.deletion_protection
}

resource "aws_cognito_resource_server" "this" {
  identifier   = var.resource_server_identifier
  name         = "${var.name_prefix}-cognito-rs-01"
  user_pool_id = aws_cognito_user_pool.this.id

  scope {
    scope_name        = var.oauth_scope_name
    scope_description = var.oauth_scope_description
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name                                 = "${var.name_prefix}-cognito-client-01"
  user_pool_id                         = aws_cognito_user_pool.this.id
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = aws_cognito_resource_server.this.scope_identifiers
  supported_identity_providers         = ["COGNITO"]
  access_token_validity                = var.access_token_validity_hours

  token_validity_units {
    access_token = "hours"
  }
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = var.domain_prefix
  user_pool_id = aws_cognito_user_pool.this.id
}
