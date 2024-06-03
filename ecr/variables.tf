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

variable "common_tags" {}

variable "image_source_url" {
  type        = string
  description = "The URL of the Dockerfile or other source used to build the images in this repository"
}
