# Athena Module

This module creates an Athena database, a workgroup, and named queries for table creation.

## Usage

```hcl
module "athena" {
  source = "github.com/nationalarchives/da-terraform-modules//athena"

  name                 = "my-database"
  result_bucket_name   = "my-query-results-bucket"
  
  create_table_queries = {
    "my_table" = templatefile("${path.module}/templates/my_table.sql.tpl", {
      table_name  = "my_table"
      bucket_name = "my-data-bucket"
      data_path   = "data"
    })
    "another_table" = templatefile("${path.module}/templates/another_table.sql.tpl", {
      table_name  = "another_table"
      bucket_name = "my-data-bucket"
      data_path   = "another_data"
    })
  }

  kms_key_arn = "arn:aws:kms:eu-west-2:account:key/..."

  # Optional
  # common_tags = {
  #   Environment = "test"
  # }
}
```

### Example Template File (templates/my_table.sql.tpl)

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS ${table_name} (
  consignmentId string,
  fileError string,
  `date` string,
  validationErrors ARRAY<STRUCT<
    assetId: string,
    errors: ARRAY<STRUCT<
      validationProcess: string,
      property: string,
      errorKey: string,
      message: string
    >>,
    data: ARRAY<STRUCT<
      name: string,
      value: string
    >>
  >>
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'ignore.malformed.json' = 'TRUE'
)
LOCATION 's3://${bucket_name}/${data_path}/';
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name to use for the Athena database and workgroup | `string` | n/a | yes |
| result_bucket_name | The name of the S3 bucket to store query results | `string` | n/a | yes |
| create_table_queries | A map of SQL queries to create the tables. Key is the query name, value is the SQL. | `map(string)` | n/a | yes |
| common_tags | Common tags to apply to resources | `map(string)` | `{}` | no |
| kms_key_arn | The ARN of the KMS key to use for encryption. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| workgroup_arn | The ARN of the Athena workgroup |
| database_name | The name of the Athena database |
| named_query_ids | Map of named query IDs created |

