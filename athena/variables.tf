variable "name" {
  description = "The name to use for the Athena database and workgroup"
  type        = string
}

variable "result_bucket_name" {
  description = "The name of the S3 bucket to store query results"
  type        = string
}

variable "create_table_queries" {
  description = "A map of SQL queries to create the tables. Key is the query name, value is the SQL."
  type        = map(string)
}

variable "common_tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "The ARN of the KMS key to use for encryption."
  type        = string
}
