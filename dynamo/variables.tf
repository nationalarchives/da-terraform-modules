variable "table_name" {}

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
