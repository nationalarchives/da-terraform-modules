locals {
  log_bucket_name  = var.create_log_bucket ? "${var.bucket_name}-logs" : var.log_bucket_name
  log_bucket_count = local.log_bucket_name != "" ? 1 : 0
}


module "data_bucket" {
  source = "../s3_prototype"

  bucket_name                            = var.bucket_name
  common_tags                            = var.common_tags
  bucket_policy                          = var.bucket_policy
  abort_incomplete_multipart_upload_days = var.abort_incomplete_multipart_upload_days

  kms_key_arn      = var.kms_key_arn
  sns_topic_config = var.sns_topic_config
}

module "log_bucket" {
  source = "../s3_logs"

  count = local.log_bucket_count

  bucket_name = local.log_bucket_name
  common_tags = var.common_tags
  bucket_policy = var.logging_bucket_policy == "" ? templatefile("${path.module}/templates/default_log_bucket_policy.json.tpl", {
    bucket_name     = var.bucket_name
    log_bucket_name = local.log_bucket_name
    account_id      = data.aws_caller_identity.current.account_id
  }) : var.logging_bucket_policy
  abort_incomplete_multipart_upload_days = var.abort_incomplete_multipart_upload_days
}


resource "aws_s3_bucket_logging" "bucket_logging" {
  count  = local.log_bucket_count
  bucket = var.bucket_name

  target_bucket = local.log_bucket_name
  target_prefix = "${var.bucket_name}/${data.aws_caller_identity.current.account_id}/"
}
