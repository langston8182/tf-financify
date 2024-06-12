locals {
  authorization_none      = "NONE"
  integration_type        = "AWS_PROXY"
  integration_http_method = "POST"
  authorizer_type         = "COGNITO_USER_POOLS"
  authorization_scopes    = ["openid"]
}