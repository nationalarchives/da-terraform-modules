resource "aws_api_gateway_rest_api" "rest_api" {
  name = var.api_name
  body = var.api_definition
  tags = var.common_tags

  dynamic "endpoint_configuration" {
    for_each = var.api_is_private ? ["do_it"] : []
    content {
      types = ["PRIVATE"]
    }
  }
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  triggers = {
    redeployment = sha1(jsonencode(concat([aws_api_gateway_rest_api.rest_api.body], local.deployment_triggers)))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = var.environment
}

resource "aws_api_gateway_rest_api_policy" "api_rest_policy" {
  count       = local.count_api_rest_policy
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  policy      = var.api_rest_policy
}

resource "aws_api_gateway_method_settings" "settings" {
  for_each    = { for config in var.api_method_settings : config.method_path => config }
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = aws_api_gateway_stage.api_stage.stage_name
  method_path = each.value.method_path

  settings {
    metrics_enabled    = each.value.metrics_enabled
    logging_level      = each.value.logging_level
    data_trace_enabled = each.value.data_trace_enabled
  }
}
