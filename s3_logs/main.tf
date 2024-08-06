module "log_bucket" {
  source = "../s3_prototype"

  bucket_name                            = var.bucket_name
  common_tags                            = var.common_tags
  bucket_policy                          = var.bucket_policy
  abort_incomplete_multipart_upload_days = var.abort_incomplete_multipart_upload_days
}
