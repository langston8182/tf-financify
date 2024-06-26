variable "dynamo_db_table_name" {
  type        = string
  description = "table name"
}

variable "dynamo_db_is_stream" {
  type = bool
}