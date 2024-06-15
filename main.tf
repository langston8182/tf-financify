module "financify_dynamodb" {
  for_each             = toset(local.table_names)
  source               = "./modules/dynamodb"
  dynamo_db_table_name = each.value
}

module "financify_lambda" {
  for_each             = local.lambdas
  source               = "./modules/lambda"
  lambda_function_name = each.value.name
  role_name            = each.value.role_name
  policy_name          = each.value.policy_name
  source_code_hash     = data.archive_file.zip_lambdas[each.value.file_name].output_base64sha256
  policy_action        = each.value.policy_actions
  policy_resource      = module.financify_dynamodb[each.value.table_name].dynamodb_arn
  env_variables        = each.value.env_variables
}

module "financify_cognito" {
  source                = "./modules/cognito"
  user_pool_name        = local.user_pool_name
  user_pool_client_name = local.user_pool_client_name
  user_pool_domain_name = local.user_pool_domain_name
  callback_urls         = local.callback_urls
  schema_fields         = local.schema_fields
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