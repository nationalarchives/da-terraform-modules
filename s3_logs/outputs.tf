output "s3_bucket_policy_json" {
  description = "s3 bucket policy json intended to be merged with other policies for the bucket built outside of the module if var.attach_s3_policy is false due to circular dependencies."
  value       = module.log_bucket.s3_bucket_policy_json
}
