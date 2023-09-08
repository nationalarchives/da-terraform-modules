resource "aws_cloudwatch_event_rule" "rule" {
  name           = var.name
  description    = var.description
  event_pattern  = var.event_pattern
  event_bus_name = var.event_bus_name
}

module "api_destination_policy" {
  source        = "../iam_policy"
  name          = "${var.name}-policy"
  policy_string = templatefile("${path.module}/templates/api_destination_policy.json.tpl", { api_destination_arn = var.api_destination_arn })
}

module "api_destination_role" {
  source             = "../iam_role"
  assume_role_policy = templatefile("${path.module}/templates/events_assume_role.json.tpl", {})
  name               = "${var.name}-role"
  policy_attachments = {
    api_destination_policy = module.api_destination_policy.policy_arn
  }
  tags = {}
}

resource "aws_cloudwatch_event_target" "target" {
  target_id      = var.name
  event_bus_name = var.event_bus_name
  arn            = var.api_destination_arn
  role_arn       = module.api_destination_role.role_arn
  rule           = aws_cloudwatch_event_rule.rule.name
  input          = var.input
  input_path     = var.input_path
  dynamic "input_transformer" {
    for_each = var.input_transformer == null ? [] : [var.input_transformer]
    content {
      input_template = input_transformer.value.input_template
      input_paths    = input_transformer.value.input_paths
    }
  }
}
