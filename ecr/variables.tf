variable "allowed_principals" {
  default = []
}

variable "expire_untagged_images_days" {
  default = 7
}

variable "repository_name" {
}

variable "repository_policy" {
  type    = string
  default = null
}

variable "lifecycle_policy" {
  type    = string
  default = null
}
