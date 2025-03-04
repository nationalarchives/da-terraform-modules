module "log_bucket" {
  source = "../s3_prototype"

  attach_s3_policy                       = var.attach_s3_policy
  bucket_name                            = var.bucket_name
  common_tags                            = var.common_tags
  kms_key_arn                            = var.kms_key_arn
  bucket_policy                          = var.bucket_policy
  abort_incomplete_multipart_upload_days = var.abort_incomplete_multipart_upload_days
}
