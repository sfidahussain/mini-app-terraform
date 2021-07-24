# Provisions a DynamoDB Table containing Rate Type, Rate Value, and Timestamp
# Lambda functions read from this table to get the latest rate,
# a specific rate, and All Rates.
# The primary key is its timestamp and that's the only attribute defined.
# The others are not needed to be defined. They are defined once a user uploads
# a file.
resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "Rates"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "timestamp"

  attribute {
    name = "timestamp"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-rates-table"
    Environment = "dev"
  }
}