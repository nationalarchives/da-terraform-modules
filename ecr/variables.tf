variable "common_tags" {}

variable "tag_mutability" {
  default = "MUTABLE"
}

variable "name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "image_source_url" {
  type        = string
  description = "The URL of the Dockerfile or other source used to build the images in this repository"
}

variable "policy" {
  description = "A string containing the ECR repository policy"
  default     = ""
}

variable "life_cycle_policy" {
  type        = string
  description = "A string containing the ECR repository life cycle policy"
}