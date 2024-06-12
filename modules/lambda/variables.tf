variable "lambda_function_name" {
  type = string
}

variable "role_name" {
  type = string
}

variable "policy_name" {
  type = string
}

variable "source_code_hash" {
  type = string
}

variable "policy_action" {
  type = list(string)
}

variable "policy_resource" {
  type = string
}

variable "env_variables" {
  type = map(string)
}
