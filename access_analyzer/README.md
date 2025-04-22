# AWS Access Analyzer Terraform Module

This Terraform module creates an **AWS Access Analyzer** instance and optionally creates an **archive rule** for filtering findings. The archive rule can be configured with specific criteria to filter access analyzer findings based on multiple comparators like `contains`, `eq`, `exists`, and `neq`.

## Table of Contents

- [Overview](#overview)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Example Usage](#example-usage)

## Overview

- **AWS Access Analyzer**: AWS Access Analyzer helps identify and understand access to AWS resources. It generates findings to detect external access (when resources are accessible by entities outside of the AWS environment) and unused access (when roles, users, or permissions are not being utilized).
- **Archive Rule**: An archive rule can be created to filter findings based on specific criteria such as user, permissions, or other conditions. This ensures that only relevant results are retained.


## Inputs

| Variable Name          | Description                                                                 | Type                                    | Default  | Required |
| ---------------------- | --------------------------------------------------------------------------- | --------------------------------------- | -------- | -------- |
| `access_analyzer_name`  | The name of the AWS Access Analyzer instance.                              | `string`                                | **Required** | Yes      |
| `access_analyzer_type`  | The type of Access Analyzer. Allowed values: `ACCOUNT`, `ORGANIZATION`, `ACCOUNT_UNUSED_ACCESS`, `ORGANIZATION_UNUSED_ACCESS`. | `string`                                | **Required** | Yes      |
| `unused_access_age`     | The number of days before access is considered unused for unused access analyzers. | `number`                                | `90`     | No       |
| `create_archive_rule`   | Flag to determine whether an archive rule should be created.               | `bool`                                  | `false`  | No       |
| `archive_rule_name`     | The name of the archive rule for AWS Access Analyzer.                       | `string`                                | `null`   | No       |
| `criteria`              | Map of filter criteria for the archive rule. The filter can have `contains`, `eq`, `exists`, and `neq` comparators. | `map(object({ contains = optional(list(string)), eq = optional(list(string)), exists = optional(bool), neq = optional(list(string)) }))` | `{}` | No       |
| `tags`                 | A map of tags to assign to the AWS Access Analyzer.               | `map(string)`                           | `{}`     | No       |

## Outputs

| Output Name             | Description                                                                 | Value Type                              |
| ----------------------- | --------------------------------------------------------------------------- | --------------------------------------- |
| `access_analyzer_name`   | The name of the AWS Access Analyzer instance.                              | `string`                                |
| `access_analyzer_arn`    | The ARN of the AWS Access Analyzer instance.                               | `string`                                |
| `archive_rule_name`      | The name of the archive rule (if created).                                 | `string` or `null`                      |

## Example Usage

### Basic Example (Creating an Access Analyzer without Archive Rule)
```hcl
module "access_analyzer" {
  source              = "path/to/this/module"
  access_analyzer_name = "example-analyzer"
  access_analyzer_type = "ACCOUNT"
  tags = {
    Account = "tna-org"
  }
}
```

### Example with Archive Rule
```hcl
module "access_analyzer" {
  source              = "path/to/this/module"
  access_analyzer_name = "example-analyzer"
  access_analyzer_type = "ACCOUNT"
  create_archive_rule  = true
  archive_rule_name    = "example-rule"
  criteria = {
    "condition.aws:UserId" = {
      eq = ["userid"]
    }
    "error" = {
      exists = true
    }
    "isPublic" = {
      eq = ["false"]
    }
  }
}
```

### Notes
- The module allows the creation of an Access Analyzer instance with a specified type (`ACCOUNT`, `ORGANIZATION`, `ACCOUNT_UNUSED_ACCESS`, or `ORGANIZATION_UNUSED_ACCESS`).
- Optionally, an archive rule can be created to filter findings based on defined criteria.
- Each filter criterion must include at least one comparator. Multiple comparators can be used for more complex filtering. The available comparators are:
  - `contains`: Used to check if the specified value contains the provided items (usually a list of strings).
  - `eq`: Used to check if the specified value is equal to the provided list of values.
  - `exists`: A boolean comparator that checks whether the specified criterion exists in the findings.
  - `neq`: Used to check if the specified value is not equal to the provided list of values.
- For more information on IAM Access Analyzer filter keys, refer to the [IAM Access Analyzer Filter Keys documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/access-analyzer-reference-filter-keys.html).
