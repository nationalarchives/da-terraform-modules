variable "attach_s3_policy" {
  description = "Whether to attach s3 bucket policy built by the inputted bucket_policy and default policies or not. Only expected to be false if the full bucket policy cannot be passesd in due to a circular dependency"
  type        = bool
  default     = true
}

variable "backup_policy_tag" {
  description = "The tag used by the central backup system to identify the bucket as a backup target. If not set, the bucket will not be backed up."
  type        = string
  default     = ""
}

variable "bucket_name" {}

variable "common_tags" {
  default = {}
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
  default     = 7
}
