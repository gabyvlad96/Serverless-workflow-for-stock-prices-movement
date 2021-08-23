resource "aws_dynamodb_table" "stock_prices" {
  name           = "Stock_prices"
  billing_mode   = "PROVISIONED"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "symbol"

  attribute {
    name = "symbol"
    type = "S"
  }
}

resource "aws_dynamodb_table" "historical_data" {
  name           = "Historical_data"
  billing_mode   = "PROVISIONED"
  read_capacity  = 3
  write_capacity = 3
  hash_key       = "symbol"

  attribute {
    name = "symbol"
    type = "S"
  }
}