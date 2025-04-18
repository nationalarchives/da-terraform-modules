resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = var.bucket_name, "BackupPolicy" = var.backup_policy_tag }
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

  dynamic "rule" {
    for_each = var.lifecycle_rules
    iterator = rule
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "expiration" {
        for_each = length(keys(lookup(rule.value, "expiration", {}))) == 0 ? [] : [rule.value.expiration]
        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [rule.value.noncurrent_version_expiration]
        content {
          noncurrent_days           = lookup(noncurrent_version_expiration.value, "noncurrent_days", null)
          newer_noncurrent_versions = lookup(noncurrent_version_expiration.value, "newer_noncurrent_versions", null)
        }
      }

      dynamic "filter" {
        for_each = length(keys(lookup(rule.value, "filter", {}))) == 0 ? [] : [rule.value.filter]
        content {
          prefix                   = lookup(filter.value, "prefix", null)
          object_size_greater_than = lookup(filter.value, "object_size_greater_than", null)
          object_size_less_than    = lookup(filter.value, "object_size_less_than", null)
          dynamic "tag" {
            for_each = length(keys(lookup(filter.value, "tag", {}))) == 0 ? [] : [filter.value.tag]
            content {
              key   = lookup(tag.value, "key")
              value = lookup(tag.value, "value")
            }
          }
        }
      }
    }
  }
}

data "aws_iam_policy_document" "policy_document" {
  source_policy_documents = var.bucket_policy == "" ? [
    templatefile(
      "${path.module}/templates/default_bucket_policy.json.tpl",
      {
        bucket_name = var.bucket_name
      }
    )
    ] : [
    var.bucket_policy,
    templatefile(
      "${path.module}/templates/default_bucket_policy.json.tpl",
      {
        bucket_name = var.bucket_name
      }
    )
  ]
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count      = var.attach_s3_policy ? 1 : 0
  bucket     = aws_s3_bucket.bucket.id
  policy     = data.aws_iam_policy_document.policy_document.json
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

