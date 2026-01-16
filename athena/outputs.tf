output "workgroup_arn" {
  value       = aws_athena_workgroup.workgroup.arn
  description = "The ARN of the Athena workgroup"
}

output "database_name" {
  value       = aws_athena_database.database.name
  description = "The name of the Athena database"
}

output "named_query_ids" {
  value       = { for k, v in aws_athena_named_query.create_table : k => v.id }
  description = "Map of Athena named query names to their corresponding query IDs."
}
