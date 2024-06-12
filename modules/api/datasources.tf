data "aws_lambda_function" "lambda_function" {
  for_each      = var.methods
  function_name = each.value.lambda
}