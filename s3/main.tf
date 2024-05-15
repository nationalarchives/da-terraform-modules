locals {
  log_bucket_count = var.create_log_bucket ? 1 : 0
  log_bucket_name  = "${var.bucket_name}-logs"
}
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = var.bucket_name }
    )
  )
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_configuration" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn == null ? "AES256" : "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "delete_incomplete_multipart_uploads" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    id     = "delete-incomplete-multipart-uploads"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = var.abort_incomplete_multipart_upload_days
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.*.id[0]
  policy = var.bucket_policy == "" ? templatefile("${path.module}/templates/default_bucket_policy.json.tpl", {
    bucket_name = var.bucket_name
  }) : var.bucket_policy
  depends_on = [aws_s3_bucket_public_access_block.bucket_public_access]
}

resource "aws_s3_bucket" "logging_bucket" {
  count  = local.log_bucket_count
  bucket = local.log_bucket_name
  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.bucket_name}-logs" }
    )
  )
}

resource "aws_s3_bucket_public_access_block" "logging_bucket_public_access" {
  count                   = local.log_bucket_count
  bucket                  = aws_s3_bucket.logging_bucket[count.index].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging_encryption_configuration" {
  count  = local.log_bucket_count
  bucket = aws_s3_bucket.logging_bucket[count.index].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "logging_versioning_example" {
  count  = local.log_bucket_count
  bucket = aws_s3_bucket.logging_bucket[count.index].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  count  = local.log_bucket_count
  bucket = aws_s3_bucket.bucket.id

  target_bucket = aws_s3_bucket.logging_bucket[count.index].id
  target_prefix = "${var.bucket_name}/${data.aws_caller_identity.current.account_id}/"
}

resource "aws_s3_bucket_policy" "logging_bucket_policy" {
  count  = local.log_bucket_count
  bucket = aws_s3_bucket.logging_bucket[count.index].id
  policy = var.logging_bucket_policy == "" ? templatefile("${path.module}/templates/default_log_bucket_policy.json.tpl", {
    bucket_name     = var.bucket_name
    log_bucket_name = local.log_bucket_name
    account_id      = data.aws_caller_identity.current.account_id
  }) : var.logging_bucket_policy
  depends_on = [aws_s3_bucket_public_access_block.bucket_public_access]
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  for_each = var.sns_topic_config
  bucket   = aws_s3_bucket.bucket.id

  topic {
    topic_arn = each.value
    events    = [each.key]
  }
}

