resource "random_uuid" "id" {}

variable "targets" {
  type = list(object({
    id       = optional(string, null),
    arn      = string
    role_arn = optional(string, null)
  }))
}

variable "name" {}
variable "description" {
  default = ""
}
variable "event_pattern" {}

variable "input_transformer" {
  type = object({
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

