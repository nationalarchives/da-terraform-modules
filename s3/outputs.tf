output "s3_bucket_arn" {
  value = "arn:aws:s3:::${var.bucket_name}"
}

output "s3_bucket_id" {
  value = module.data_bucket.s3_bucket_id
}
