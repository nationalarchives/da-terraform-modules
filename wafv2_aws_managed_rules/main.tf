resource "aws_wafv2_ip_set" "allow_list" {
  count              = length(var.ip_restrictions_configuration.ip_list) > 0 ? 1 : 0
  name               = "ip-allow-list"
  addresses          = var.ip_restrictions_configuration.ip_list
  ip_address_version = "IPV4"
  scope              = var.scope
}

resource "aws_wafv2_web_acl" "aws_managed_rules" {
  name  = "AWS-Managed-Rules"
  scope = var.scope
  dynamic "default_action" {
    for_each = var.default_action == "block" ? [""] : []
    content {
      block {}
    }
  }

  dynamic "default_action" {
    for_each = var.default_action == "allow" ? [""] : []
    content {
      allow {}
    }
  }

  dynamic "rule" {
    for_each = length(var.ip_restrictions_configuration.ip_list) > 0 ? [""] : []
    content {
      name     = "AllowIPs"
      priority = length(var.aws_managed_rules) + 1
      action {
        block {}
      }
      visibility_config {
        cloudwatch_metrics_enabled = var.ip_restrictions_configuration.cloudwatch_metrics_enabled
        metric_name                = "AllowIpMetric"
        sampled_requests_enabled   = var.ip_restrictions_configuration.sampled_requests_enabled
      }
      dynamic "statement" {
        for_each = var.ip_restrictions_configuration.action == "allow" ? [""] : []
        content {
          not_statement {
            statement {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.allow_list[0].arn
              }
            }
          }
        }
      }
      dynamic "statement" {
        for_each = var.ip_restrictions_configuration.action == "block" ? [""] : []
        content {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.allow_list[0].arn
          }
        }
      }
    }
  }

  dynamic "rule" {
    for_each = toset(var.aws_managed_rules)
    content {
      name     = rule.value.name
      priority = rule.value.priority
      override_action {
        none {}
      }
      statement {
        managed_rule_group_statement {
          name        = rule.value.managed_rule_group_statement_name
          vendor_name = rule.value.managed_rule_group_statement_vendor_name
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = false
        metric_name                = rule.value.metric_name
        sampled_requests_enabled   = false
      }
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "AWS-Managed-Rules"
    sampled_requests_enabled   = false
  }
  tags = var.tags
}

resource "aws_wafv2_web_acl_association" "waf_association_aws_managed_rules" {
  count        = length(var.arn_associations)
  resource_arn = var.arn_associations[count.index]
  web_acl_arn  = aws_wafv2_web_acl.aws_managed_rules.arn
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_logging_aws_managed_rules" {
  log_destination_configs = var.log_destinations
  resource_arn            = aws_wafv2_web_acl.aws_managed_rules.arn
}
