resource "aws_cloudwatch_event_rule" "rule" {
  name        = var.name
  description = var.description
  event_pattern = var.event_pattern
}

resource "aws_cloudwatch_event_target" "target" {
  for_each          = var.targets
  id                = each.value.id == null ? "$Id${uuid()}" : each.value.id
  target_id         = var.name
  arn               = each.value.arn
  role_arn          = each.value.role_arn
  rule              = aws_cloudwatch_event_rule.rule.name
  input             = var.input
  input_path        = var.input_path
  dynamic "input_transformer" {
    for_each = var.input_transformer == null ? [] : [var.input_transformer]
    content {
      input_template = each.value.input_template
      input_paths = each.value.input_paths
    }
  }
}
