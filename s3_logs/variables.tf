variable "bucket_name" {}

variable "common_tags" {
  default = {}
}

variable "bucket_policy" {
  default = ""
}

variable "abort_incomplete_multipart_upload_days" {
  description = "The number of days to keep an incomplete multipart upload before it is deleted"
  default     = 7
}
