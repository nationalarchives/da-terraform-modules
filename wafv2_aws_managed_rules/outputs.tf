output "waf_arn" {
  value = aws_wafv2_web_acl.aws_managed_rules.arn
}