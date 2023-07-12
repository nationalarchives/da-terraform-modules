output "kms_key_arn" {
  value = aws_kms_key.encryption.arn
}

output "kms_key_alias" {
  value = aws_kms_alias.encryption.name
}
