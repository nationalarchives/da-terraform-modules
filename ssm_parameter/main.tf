resource "aws_ssm_parameter" "ssm_parameter" {
  for_each    = { for ssm_parameter in var.parameters : ssm_parameter.name => ssm_parameter if ssm_parameter.ignore_value }
  name        = each.value.name
  type        = each.value.type
  value       = each.value.value
  description = each.value.description
  tier        = each.value.tier
  overwrite   = each.value.overwrite
  tags        = var.tags
}

resource "aws_ssm_parameter" "ssm_parameter_ignore_value" {
  for_each    = { for ssm_parameter in var.parameters : ssm_parameter.name => ssm_parameter if !ssm_parameter.ignore_value }
  name        = each.value.name
  type        = each.value.type
  value       = each.value.value
  description = each.value.description
  tier        = each.value.tier
  overwrite   = each.value.overwrite
  tags        = var.tags
  lifecycle {
    ignore_changes = [value]
  }
}
