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
    for_each = var.api_destination_input_transformer == null ? [] : [var.api_destination_input_transformer]
    content {
      input_template = input_transformer.value.input_template
      input_paths    = input_transformer.value.input_paths
    }
  }
}
resource "aws_cloudwatch_log_group" "event_target_log_group" {
  count             = var.log_group_destination_input_transformer == null ? 0 : 1
  name              = "/aws/events/${var.log_group_destination_input_transformer.log_group_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_event_target" "step_function_failure_cloudwatch_target" {
  count = var.log_group_destination_input_transformer == null ? 0 : 1
  arn   = aws_cloudwatch_log_group.event_target_log_group[count.index].arn
  rule  = aws_cloudwatch_event_rule.rule.name
  dynamic "input_transformer" {
    for_each = var.log_group_destination_input_transformer == null ? [] : [var.log_group_destination_input_transformer]
    content {
      input_template = input_transformer.value.input_template
      input_paths    = input_transformer.value.input_paths
    }
  }
}

resource "aws_cloudwatch_event_target" "step_function_failure_lambda_target" {
  count = var.lambda_target_arn == null ? 0 : 1
  arn   = var.lambda_target_arn
  rule  = aws_cloudwatch_event_rule.rule.name
}
