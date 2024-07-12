resource "aws_dynamodb_table" "table" {
  name                        = var.table_name
  billing_mode                = var.billing_mode
  read_capacity               = var.billing_mode == "PAY_PER_REQUEST" ? null : var.read_capacity
  write_capacity              = var.billing_mode == "PAY_PER_REQUEST" ? null : var.write_capacity
  hash_key                    = var.hash_key.name
  range_key                   = var.range_key.name == null ? null : var.range_key.name
  deletion_protection_enabled = var.deletion_protection_enabled
  stream_enabled              = var.stream_enabled
  stream_view_type            = var.stream_enabled == false ? null : "NEW_IMAGE"

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  server_side_encryption {
    enabled     = var.server_side_encryption_enabled
    kms_key_arn = var.kms_key_arn
  }

  dynamic "ttl" {
    for_each = var.ttl_attribute_name == null ? [] : [var.ttl_attribute_name]
    iterator = attr_name
    content {
      attribute_name = attr_name.value
      enabled        = true
    }
  }

  dynamic "attribute" {
    for_each = toset(flatten([var.range_key.name == null ? [] : [var.range_key], var.additional_attributes, [var.hash_key]]))
    iterator = attr
    content {
      name = attr.value.name
      type = attr.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    iterator = idx
    content {
      name               = idx.value.name
      hash_key           = idx.value.hash_key
      range_key          = idx.value.range_key
      write_capacity     = idx.value.write_capacity
      read_capacity      = idx.value.read_capacity
      projection_type    = idx.value.projection_type
      non_key_attributes = idx.value.non_key_attributes
    }
  }

  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = var.table_name }
    )
  )
}

resource "aws_dynamodb_resource_policy" "require_ssl" {
  resource_arn = aws_dynamodb_table.table.arn
  policy       = templatefile("${path.module}/templates/dynamo_require_ssl.json.tpl", { table_arn = aws_dynamodb_table.table.arn })
}
