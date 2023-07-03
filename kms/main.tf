resource "aws_kms_key" "encryption" {
  description         = var.key_description
  enable_key_rotation = true
  policy              = var.key_policy
  tags = merge(
    var.tags,
    tomap(
      { "Name" = var.key_name }
    )
  )
}

resource "aws_kms_alias" "encryption" {
  name          = "alias/${var.key_name}"
  target_key_id = aws_kms_key.encryption.key_id
}
