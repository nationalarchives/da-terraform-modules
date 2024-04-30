variable "create_log_bucket" {
  default = true
}

variable "bucket_name" {}

variable "common_tags" {
  default = {}
}

variable "logging_bucket_policy" {
  default = ""
}

variable "bucket_policy" {
  default = ""
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
  default     = 30
}

variable "use_random_suffix" {
  type    = bool
  default = false
}