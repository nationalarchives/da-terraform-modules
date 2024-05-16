variable "invocation_rate" {
  default = 300
}
variable "http_method" {
  default = "POST"
}
variable "invocation_endpoint" {
  default = "https://slack.com/api/chat.postMessage"
}
variable "description" {
  default = ""
}
variable "name" {}
variable "authorisation_header_value" {}

variable "headers" {
  type    = map(string)
  default = {}
}