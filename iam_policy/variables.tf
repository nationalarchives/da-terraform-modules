variable "name" {}

variable "policy_string" {}

variable "description" {
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
