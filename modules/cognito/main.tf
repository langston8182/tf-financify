resource "aws_cognito_user_pool" "user_pool" {
  name = var.user_pool_name
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
  username_attributes      = local.username_attributes
  auto_verified_attributes = local.auto_verified_attributes
  email_configuration {
    email_sending_account = local.email_sending_account
  }
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
  dynamic "schema" {
    for_each = var.schema_fields
    content {
      attribute_data_type = schema.value.type
      name                = schema.key
      required            = schema.value.required
      mutable             = schema.value.mutable
    }
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name                                 = var.user_pool_client_name
  user_pool_id                         = aws_cognito_user_pool.user_pool.id
  callback_urls                        = var.callback_urls
  allowed_oauth_flows                  = local.allowed_oauth_flows
  allowed_oauth_scopes                 = local.allowed_oauth_scopes
  explicit_auth_flows                  = local.explicit_auth_flows
  supported_identity_providers         = local.supported_identity_providers
  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = false
  read_attributes                      = keys(var.schema_fields)
  write_attributes                     = keys(var.schema_fields)
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain       = var.user_pool_domain_name
  user_pool_id = aws_cognito_user_pool.user_pool.id
}