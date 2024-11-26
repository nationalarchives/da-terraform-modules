terraform {
  required_version = ">= 1.6.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  log_bucket_count     = var.create_log_bucket ? 1 : 0
  log_bucket_name      = var.create_log_bucket ? "${var.bucket_name}-logs" : var.log_bucket_name
  bucket_logging_count = local.log_bucket_name != "" ? 1 : 0
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
  count = local.log_bucket_count

  source = "../s3_logs"

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
  count = local.bucket_logging_count

  bucket        = var.bucket_name
  target_bucket = local.log_bucket_name
  target_prefix = "${var.bucket_name}/${data.aws_caller_identity.current.account_id}/"
}
