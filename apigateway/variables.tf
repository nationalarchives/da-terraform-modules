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

variable "api_method_settings" {
  type = list(object({
    method_path        = string,
    logging_level      = string,
    metrics_enabled    = bool,
    data_trace_enabled = bool
  }))
  default     = []
  description = "A list of method setting for the API. See here for details logging level settings: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings"
}

variable "endpoint_configuration" {
  type = object({
    ip_address_type  = optional(string)
    types            = list(string)
    vpc_endpoint_ids = optional(list(string))
  })
  description = "An endpoint configuration block"
  default = {
    types = []
  }
}
