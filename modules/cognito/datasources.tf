data "aws_lambda_function" "lambda_function" {
  function_name = var.lambda_name_function_post_authentication
}
