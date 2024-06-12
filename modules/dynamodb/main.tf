resource "aws_dynamodb_table" "dynamodb" {
  name         = var.dynamo_db_table_name
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "id"
    type = "S"
  }
  hash_key = "id"
}