variable "api_name" {
  description = "The name of the API"
  type        = string
}

variable "resources" {
  type = map(object({
    path   = string
    parent = string
  }))
}

variable "methods" {
  type = map(object({
    resource      = string
    is_root       = bool
    is_authorized = bool
    http_method   = string
    lambda        = string
    http_method   = string
  }))
}

variable "stage_name" {
  type = string
}

variable "authorizer_name" {
  type = string
}

variable "user_pool_arn" {
  type = string
}