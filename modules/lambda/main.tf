resource "aws_lambda_function" "lambda_function" {
  function_name    = var.lambda_function_name
  filename         = local.lambda_filename
  handler          = "${var.lambda_function_name}.handler"
  runtime          = local.lambda_runtime
  package_type     = local.lambda_package_type
  source_code_hash = var.source_code_hash
  role             = aws_iam_role.lambda_role.arn
  environment {
    variables = var.env_variables
  }
}

resource "aws_iam_role" "lambda_role" {
  name                = var.role_name
  assume_role_policy  = data.aws_iam_policy_document.lambda_assume_role.json
  managed_policy_arns = [aws_iam_policy.lambda_policy.arn]
}

resource "aws_iam_policy" "lambda_policy" {
  name   = var.policy_name
  policy = jsonencode(
    {
      Version   = local.policy_version
      Statement = [
        {
          Action   = var.policy_action
          Effect   = "Allow"
          Resource = var.policy_resource
          Sid      = "VisualEditor0"
        }
      ]
    }
  )
}