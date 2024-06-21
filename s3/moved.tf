
moved {
  from = aws_s3_bucket.bucket
  to   = module.data_bucket.aws_s3_bucket.bucket
}

moved {
  from = aws_s3_bucket_public_access_block.bucket_public_access
  to   = module.data_bucket.aws_s3_bucket_public_access_block.bucket_public_access
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.encryption_configuration
  to   = module.data_bucket.aws_s3_bucket_server_side_encryption_configuration.encryption_configuration
}

moved {
  from = aws_s3_bucket_versioning.versioning
  to   = module.data_bucket.aws_s3_bucket_versioning.versioning
}

moved {
  from = aws_s3_bucket_lifecycle_configuration.delete_incomplete_multipart_uploads
  to   = module.data_bucket.aws_s3_bucket_lifecycle_configuration.delete_incomplete_multipart_uploads
}

moved {
  from = aws_s3_bucket_policy.bucket_policy
  to   = module.data_bucket.aws_s3_bucket_policy.bucket_policy
}

moved {
  from = aws_s3_bucket_notification.bucket_notification
  to   = module.data_bucket.aws_s3_bucket_notification.bucket_notification
}

moved {
  from = aws_s3_bucket.logging_bucket[0]
  to   = module.log_bucket[0].module.log_bucket.aws_s3_bucket.bucket
}

moved {
  from = aws_s3_bucket_public_access_block.logging_bucket_public_access[0]
  to   = module.log_bucket[0].module.log_bucket.aws_s3_bucket_public_access_block.bucket_public_access
}

moved {
  from = aws_s3_bucket_server_side_encryption_configuration.logging_encryption_configuration[0]
  to   = module.log_bucket[0].module.log_bucket.aws_s3_bucket_server_side_encryption_configuration.encryption_configuration
}

moved {
  from = aws_s3_bucket_versioning.logging_versioning_example[0]
  to   = module.log_bucket[0].module.log_bucket.aws_s3_bucket_versioning.versioning
}

moved {
  from = aws_s3_bucket_policy.logging_bucket_policy[0]
  to   = module.log_bucket[0].module.log_bucket.aws_s3_bucket_policy.bucket_policy
}
