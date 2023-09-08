variable "api_destination_arn" {}

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

variable "event_bus_name" {
  default = "default"
}
