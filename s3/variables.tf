variable "create_log_bucket" {
  default = true
}

variable "backup_policy_tag" {
  description = "The tag used by the central backup system to identify the bucket as a backup target. If not set, the bucket will not be backed up."
  type        = string
  default     = ""
}

variable "log_bucket_name" {
  default = ""
}

variable "bucket_name" {}

variable "common_tags" {
  default = {}
}

variable "logging_bucket_policy" {
  default     = ""
  description = "Additional logging bucket policy to be added to a default policy."
}

variable "bucket_policy" {
  default     = ""
  description = "Additional bucket policy to be added to a default policy with sid AllowSSLRequestsOnly that denies non SSL requests."
}

variable "sns_topic_config" {
  type    = map(string)
  default = {}
}

variable "kms_key_arn" {
  default = null
}

variable "abort_incomplete_multipart_upload_days" {
  description = "The number of days to keep an incomplete multipart upload before it is deleted"
  default     = 7
}

variable "s3_data_bucket_additional_tags" {
  description = "Set of tags to be applied to the S3 bucket only"
  default     = null
}

variable "s3_logs_bucket_additional_tags" {
  description = "Set of tags to be applied to the S3 logs bucket only"
  default     = null
}

variable "lifecycle_rules" {
  description = "List of maps describing configuration of object lifecycle management for bucket"
  type        = any
  default     = []
}
