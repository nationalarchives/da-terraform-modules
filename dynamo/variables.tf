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

variable "hash_key" {}

variable "hash_key_type" {}

variable "common_tags" {
  default = {}
}

variable "deletion_protection_enabled" {
  default = false
}
