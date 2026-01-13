locals {
  count_api_rest_policy = var.api_rest_policy == "" ? 0 : 1
  deployment_triggers   = local.count_api_rest_policy == 1 ? [aws_api_gateway_rest_api_policy.api_rest_policy[0].id] : []
}
