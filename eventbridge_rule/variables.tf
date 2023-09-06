resource "random_uuid" "id" {}

variable "targets" {
  type = list(object({
    id       = optional(string, random_uuid.id.result),
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
