output "access_analyzer_name" {
  description = "The name of the AWS Access Analyzer instance."
  value       = aws_accessanalyzer_analyzer.access_analyzer.analyzer_name
}

output "access_analyzer_arn" {
  description = "The ARN of the AWS Access Analyzer instance."
  value       = aws_accessanalyzer_analyzer.access_analyzer.arn
}

output "archive_rule_name" {
  description = "The name of the archive rule (if created)."
  value       = var.create_archive_rule ? aws_accessanalyzer_archive_rule.access_analyzer_archive_rule[0].rule_name : null
}
