resource "aws_accessanalyzer_analyzer" "access_analyzer" {
  analyzer_name = var.access_analyzer_name
  type          = var.access_analyzer_type
  dynamic "configuration" {
    for_each = contains(["ACCOUNT_UNUSED_ACCESS", "ORGANIZATION_UNUSED_ACCESS"], var.access_analyzer_type) ? [1] : []
    content {
      unused_access {
        unused_access_age = var.unused_access_age
      }
    }
  }
  tags = var.tags
}

resource "aws_accessanalyzer_archive_rule" "access_analyzer_archive_rule" {
  count         = var.create_archive_rule ? 1 : 0
  analyzer_name = aws_accessanalyzer_analyzer.access_analyzer.analyzer_name
  rule_name     = var.archive_rule_name
  dynamic "filter" {
    for_each = var.criteria
    iterator = "criteria"
    content {
      criteria = criteria.key
      contains = lookup(criteria.value, "contains", null)
      eq       = lookup(criteria.value, "eq", null)
      exists   = lookup(criteria.value, "exists", null)
      neq      = lookup(criteria.value, "neq", null)
    }
  }
}
