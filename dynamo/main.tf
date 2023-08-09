resource "aws_dynamodb_table" "table" {
  name                        = var.table_name
  billing_mode                = var.billing_mode
  read_capacity               = var.billing_mode == "PAY_PER_REQUEST" ? null : var.read_capacity
  write_capacity              = var.billing_mode == "PAY_PER_REQUEST" ? null : var.write_capacity
  hash_key                    = var.hash_key
  deletion_protection_enabled = var.deletion_protection_enabled
  server_side_encryption {
    enabled     = var.server_side_encryption_enabled
    kms_key_arn = var.kms_key_arn
  }

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = var.table_name }
    )
  )
}
