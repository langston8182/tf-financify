module "financify_dynamodb" {
  for_each             = toset(local.table_names)
  source               = "./modules/dynamodb"
  dynamo_db_is_stream  = each.value == local.dynamodb_table_name_user ? true : false
  dynamo_db_table_name = each.value
}

module "financify_lambda" {
  for_each             = local.lambdas
  source               = "./modules/lambda"
  lambda_function_name = each.value.name
  role_name            = each.value.role_name
  policy_name          = each.value.policy_name
  source_code_hash     = data.archive_file.zip_lambdas[each.value.file_name].output_base64sha256
  policy_statement     = each.value.policy_statement
  env_variables        = each.value.env_variables
}

module "financify_lambda_dynamodb_trigger" {
  source               = "./modules/lambda"
  lambda_function_name = local.lambda_trigger_dynamodb_modify_cognito.name
  role_name            = local.lambda_trigger_dynamodb_modify_cognito.role_name
  policy_name          = local.lambda_trigger_dynamodb_modify_cognito.policy_name
  source_code_hash     = data.archive_file.zip_lambdas[local.lambda_trigger_dynamodb_modify_cognito.file_name].output_base64sha256
  policy_statement     = local.lambda_trigger_dynamodb_modify_cognito.policy_statement
  env_variables        = local.lambda_trigger_dynamodb_modify_cognito.env_variables
}

resource "aws_lambda_event_source_mapping" "dynamodb_trigger" {
  depends_on        = [module.financify_lambda_dynamodb_trigger, module.financify_dynamodb]
  function_name     = local.lambda_function_name_trigger_dynamodb_modidy_cognito
  event_source_arn  = module.financify_dynamodb[local.dynamodb_table_name_user].dynamodb_stream_arn
  starting_position = "LATEST"
}

module "financify_cognito" {
  depends_on                               = [module.financify_lambda]
  source                                   = "./modules/cognito"
  user_pool_name                           = local.user_pool_name
  user_pool_client_name                    = local.user_pool_client_name
  user_pool_domain_name                    = local.user_pool_domain_name
  callback_urls                            = local.callback_urls
  schema_fields                            = local.schema_fields
  lambda_name_function_post_authentication = local.lambda_function_name_add_user_from_cognito
}

module "financify_api" {
  depends_on      = [module.financify_lambda]
  source          = "./modules/api"
  api_name        = local.api_name
  stage_name      = local.env
  resources       = local.api_resources
  methods         = local.api_methods
  authorizer_name = local.authorizer_name
  user_pool_arn   = module.financify_cognito.arn
}

module "financify_domain" {
  source      = "./modules/domain"
  domain_name = local.domain_name
  rest_api_id = module.financify_api.api_id
  stage_name  = local.env
  zone_id     = local.route53_zone_id
}