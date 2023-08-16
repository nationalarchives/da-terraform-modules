variable "table_name" {}

variable "billing_mode" {
  default = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  default = 5
}

variable "write_capacity" {
  default = 5
}

variable "hash_key" {
  type = object({ type = string, name = string })
}

variable "range_key" {
  type    = object({ type = optional(string), name = optional(string) })
  default = {}
}

variable "additional_attributes" {
  type    = list(object({ type = string, name = string }))
  default = []
}

variable "common_tags" {
  default = {}
}

variable "global_secondary_indexes" {
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    write_capacity     = optional(number)
    read_capacity      = optional(number)
    projection_type    = string
    non_key_attributes = optional(list(string), [])
  }))
  default = []
}

variable "deletion_protection_enabled" {
  default = false
}

# If enabled is false then server-side encryption is set to AWS-owned key (shown as DEFAULT in the AWS console).
# If enabled is true and no kms_key_arn is specified then server-side encryption is set to the default KMS-managed key (shown as KMS in the AWS console).
# See documentation here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table#server_side_encryption
variable "server_side_encryption_enabled" {
  default = false
}

variable "kms_key_arn" {
  default = ""
}
