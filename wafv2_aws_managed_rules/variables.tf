variable "log_destinations" {
  description = "A list of destinations to send the waf logs to"
  type        = list(string)
  default     = []
}

variable "scope" {
  default = "REGIONAL"
}

variable "default_action" {
  default = "block"
}

variable "arn_associations" {
  description = "List of AWS resource ARNs for WAF rule association"
  default     = []
}

variable "ip_restrictions_configuration" {
  type = object({
    ip_list                    = optional(list(string), [])
    action                     = optional(string, "block")
    cloudwatch_metrics_enabled = optional(bool, false)
    sampled_requests_enabled   = optional(bool, false)

  })
  default = {}
}

variable "aws_managed_rules" {
  description = "List of AWS managed rules to be applied"
  type = list(object({
    name                                     = string
    priority                                 = number
    managed_rule_group_statement_name        = string
    managed_rule_group_statement_vendor_name = string
    metric_name                              = string
  }))
  default = [
    {
      name                                     = "AWS-AWSManagedRulesAmazonIpReputationList"
      priority                                 = 0
      managed_rule_group_statement_name        = "AWSManagedRulesAmazonIpReputationList"
      managed_rule_group_statement_vendor_name = "AWS"
      metric_name                              = "AWS-AWSManagedRulesAmazonIpReputationList"
    },
    {
      name                                     = "AWS-AWSManagedRulesCommonRuleSet"
      priority                                 = 1
      managed_rule_group_statement_name        = "AWSManagedRulesCommonRuleSet"
      managed_rule_group_statement_vendor_name = "AWS"
      metric_name                              = "AWS-AWSManagedRulesCommonRuleSet"
    },
    {
      name                                     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      priority                                 = 2
      managed_rule_group_statement_name        = "AWSManagedRulesKnownBadInputsRuleSet"
      managed_rule_group_statement_vendor_name = "AWS"
      metric_name                              = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    },
  ]
}

variable "tags" {
  description = "tags used across the project"
  default     = {}
}
