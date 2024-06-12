variable "user_pool_name" {
  type = string
}

variable "user_pool_client_name" {
  type = string
}

variable "user_pool_domain_name" {
  type = string
}

variable "callback_urls" {
  type = list(string)
}

variable "schema_fields" {
  type = map(object({
    required = bool
    mutable  = bool
    type     = string
  }))
}
