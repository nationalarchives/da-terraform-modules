resource "aws_athena_database" "database" {
  name   = var.name
  bucket = var.result_bucket_name

  encryption_configuration {
    encryption_option = "SSE_KMS"
    kms_key_arn       = var.kms_key_arn
  }
}

resource "aws_athena_workgroup" "workgroup" {
  name = var.name

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.result_bucket_name}/results/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = var.kms_key_arn
      }
    }
  }

  force_destroy = true

  tags = var.common_tags
}

resource "aws_athena_named_query" "create_table" {
  for_each  = var.create_table_queries
  name      = "${var.name}-${each.key}"
  workgroup = aws_athena_workgroup.workgroup.id
  database  = aws_athena_database.database.name
  query     = each.value
}
