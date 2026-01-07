output "workgroup_arn" {
  value = aws_athena_workgroup.workgroup.arn
}

output "database_name" {
  value = aws_athena_database.database.name
}

output "named_query_ids" {
  value = { for k, v in aws_athena_named_query.create_table : k => v.id }
}

