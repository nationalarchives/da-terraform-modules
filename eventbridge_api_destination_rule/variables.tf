variable "api_destination_arn" {}

variable "name" {}
variable "description" {
  default = ""
}
variable "event_pattern" {}

variable "api_destination_input_transformer" {
  type = object({
    input_paths    = map(string)
    input_template = string
  })
  default = null
}

variable "log_group_destination_input_transformer" {
  type = object({
    log_group_name = string
    input_paths    = map(string)
    input_template = string
  })
  default = null
}

variable "input" {
  default = null
}
variable "input_path" {
  default = null
}

variable "event_bus_name" {
  default = "default"
}

variable "lambda_target_arn" {
  description = "A lambda arn to be used as an event target"
  default     = null
}

variable "rule_state" {
  description = "The rule state. Defaults to ENABLED which allows terraform to detect changes made manually to the state. Set to null to ignore manual state changes"
  default     = "ENABLED"
}