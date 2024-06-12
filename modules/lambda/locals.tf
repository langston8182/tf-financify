locals {
  lambda_runtime      = "nodejs20.x"
  lambda_package_type = "Zip"
  lambda_filename     = "${path.module}/files/${var.lambda_function_name}.mjs.zip"

  policy_version = "2012-10-17"
}