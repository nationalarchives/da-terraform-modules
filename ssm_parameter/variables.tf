variable "parameters" {
  type = set(object({
    name         = string
    type         = string
    value        = string
    description  = string
    tier         = optional(string)
    ignore_value = optional(bool, false)
    overwrite    = optional(bool, true)
  }))
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
