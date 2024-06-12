resource "aws_api_gateway_rest_api" "rest_api" {
  name = var.api_name
}

resource "aws_api_gateway_resource" "initial_api_resource" {
  for_each    = {for k, v in var.resources : k => v if v.parent == null}
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = each.value.path
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}

resource "aws_api_gateway_resource" "api_resource" {
  for_each    = {for k, v in var.resources : k => v if v.parent != null}
  parent_id   = aws_api_gateway_resource.initial_api_resource[each.value.parent].id
  path_part   = each.value.path
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}

resource "aws_api_gateway_method" "api_method" {
  for_each             = var.methods
  authorization        = each.value.is_authorized ? local.authorizer_type : local.authorization_none
  authorizer_id        = each.value.is_authorized ? aws_api_gateway_authorizer.authorizer.id : null
  authorization_scopes = local.authorization_scopes
  http_method          = each.value.http_method
  resource_id          = each.value.is_root ? aws_api_gateway_resource.initial_api_resource[each.value.resource].id : aws_api_gateway_resource.api_resource[each.value.resource].id
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
}

resource "aws_api_gateway_integration" "integration" {
  for_each                = var.methods
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = each.value.is_root ? aws_api_gateway_resource.initial_api_resource[each.value.resource].id : aws_api_gateway_resource.api_resource[each.value.resource].id
  http_method             = aws_api_gateway_method.api_method[each.key].http_method
  integration_http_method = local.integration_http_method
  type                    = local.integration_type
  uri                     = data.aws_lambda_function.lambda_function[each.key].invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on  = [aws_api_gateway_integration.integration]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = var.stage_name
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name          = var.authorizer_name
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  type          = local.authorizer_type
  provider_arns = [var.user_pool_arn]
}

resource "aws_lambda_permission" "apigw" {
  for_each      = var.methods
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.lambda_function[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
}