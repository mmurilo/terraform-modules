resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = local.dynamodb_table_name
  hash_key       = "LockID"
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  server_side_encryption {
    enabled = true
  }
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name        = local.dynamodb_table_name
    Description = "DynamoDB Terraform State Lock Table"
    managed_by  = var.creator
  }
  lifecycle {
    prevent_destroy = true
  }
}
