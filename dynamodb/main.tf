provider "aws" {
  region  = "eu-central-1"
  profile = "default"
}

resource "aws_dynamodb_table" "table" {
  name         = "table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "UserId"
  range_key    = "GameTitle"

  attribute {
    name = "UserId"
    type = "S"
  }

  attribute {
    name = "GameTitle"
    type = "S"
  }
}
