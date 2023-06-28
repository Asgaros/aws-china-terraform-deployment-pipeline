resource "aws_dynamodb_table" "infrastructure_locks_table" {
  name = var.infrastructure_locks_table_name

  # Pay per request is cheaper for low-I/O applications, like our Terraform lock state.
  billing_mode = "PAY_PER_REQUEST"

  # Hash key is required, and must be an attribute.
  hash_key = "LockID"

  # Attribute LockID is required for Terraform to use this table for lock state.
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = var.infrastructure_locks_table_name
  }
}
