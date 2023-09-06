variable "invocation_rate" {
  default = 300
}
variable "http_method" {
  default = "POST"
}
variable "invocation_endpoint" {}
variable "description" {
  default = ""
}
variable "name" {}
variable "authorisation_header_value" {}

resource "aws_cloudwatch_event_connection" "api_connection" {
  name               = "${var.name}-connection"
  description        = "A connection for ${var.description}"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "Authorization"
      value = var.authorisation_header_value
    }
  }
}

resource "aws_cloudwatch_event_api_destination" "api_destination" {
  name                             = var.name
  description                      = var.description
  invocation_endpoint              = var.invocation_endpoint
  http_method                      = var.http_method
  invocation_rate_limit_per_second = var.invocation_rate
  connection_arn                   = aws_cloudwatch_event_connection.api_connection.arn
}
