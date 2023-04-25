variable "create_log_bucket" {
  default = true
}

variable "bucket_name" {}

variable "common_tags" {
  default = {}
}

variable "acl" {
  default = "private"
}

variable "logging_bucket_policy" {
  default = ""
}

variable "bucket_policy" {
  default = ""
}
