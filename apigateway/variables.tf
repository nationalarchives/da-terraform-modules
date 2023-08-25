variable "api_definition" {
  description = "The json definition of the API"
}

variable "api_name" {}

variable "common_tags" {
  default = {}
}

variable "environment" {}

variable "api_rest_policy" {
  default = ""
}

variable "region" {
  default = "eu-west-2"
}
