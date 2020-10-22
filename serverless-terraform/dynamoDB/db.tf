
variable "db_name"{
  default = "dynamodb"
}

resource "aws_dynamodb_table" "dynamodb" {
  name           = var.db_name
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "fileID"


  attribute {
    name = "fileID"
    type = "S"
  }



}

output "dynamodb_table_arn" {
  value= aws_dynamodb_table.dynamodb.arn
}
