variable "create_log_bucket" {
  default = true
}

variable "log_bucket_name" {
  default = ""
}

variable "bucket_name" {}

variable "common_tags" {
  default = {}
}

variable "logging_bucket_policy" {
  default = "Additional logging bucket policy to be added to a default policy."
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
