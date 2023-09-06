resource "aws_cloudwatch_event_rule" "rule" {
  name        = var.name
  description = var.description

  event_pattern = var.event_pattern
}

variable "input" {
  default = null
}
variable "input_path" {
  default = null
}


resource "aws_cloudwatch_event_target" "target" {
  for_each          = var.targets
  id                = each.value.id
  target_id         = var.name
  arn               = each.value.arn
  role_arn          = each.value.role_arn
  rule              = aws_cloudwatch_event_rule.rule.name
  input             = var.input
  input_path        = var.input_path
  input_transformer = var.input_transformer
}
