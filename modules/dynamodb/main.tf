resource "aws_dynamodb_table" "dynamodb" {
  name         = var.dynamo_db_table_name
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "id"
    type = "S"
  }
  hash_key         = "id"
  stream_enabled   = var.dynamo_db_is_stream ? true : null
  stream_view_type = var.dynamo_db_is_stream ? local.dynamo_db_stream_type : null
}