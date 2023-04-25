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
      sse_algorithm = "AES256"
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

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket     = aws_s3_bucket.bucket.*.id[0]
  policy     = var.bucket_policy
  depends_on = [aws_s3_bucket_public_access_block.bucket_public_access]
}

resource "aws_s3_bucket" "logging_bucket" {
  count  = var.create_log_bucket ? 1 : 0
  bucket = "${var.bucket_name}-logs"
  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = "${var.bucket_name}-logs" }
    )
  )
}

resource "aws_s3_bucket_public_access_block" "logging_bucket_public_access" {
  count                   = var.create_log_bucket ? 1 : 0
  bucket                  = aws_s3_bucket.logging_bucket[count.index].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging_encryption_configuration" {
  count  = var.create_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.logging_bucket[count.index].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "logging_versioning_example" {
  count  = var.create_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.logging_bucket[count.index].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  count  = var.create_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  target_bucket = aws_s3_bucket.logging_bucket[count.index].id
  target_prefix = "${var.bucket_name}/${data.aws_caller_identity.current.account_id}/"
}

resource "aws_s3_bucket_policy" "logging_bucket_policy" {
  bucket     = aws_s3_bucket.bucket.*.id[0]
  policy     = var.logging_bucket_policy
  depends_on = [aws_s3_bucket_public_access_block.bucket_public_access]
}
