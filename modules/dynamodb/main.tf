resource "aws_dynamodb_table" "this" {
  name         = "${var.env}-${var.table_name_suffix}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
