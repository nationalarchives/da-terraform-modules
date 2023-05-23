variable "queue_name" {}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "sqs_policy" {
  description = "A string containing the SQS policy"
}

variable "redrive_maximum_receives" {
  default = 0
}

variable "visibility_timeout" {
  default = 30
}

variable "kms_key_id" {}

variable "message_retention_seconds" {
  type    = number
  default = 1209600
}

variable "max_message_size" {
  type    = number
  default = 262144
}

variable "delay_seconds" {
  type    = number
  default = 0
}

variable "receive_wait_time_seconds" {
  type    = number
  default = 0
}

variable "fifo_queue" {
  type    = bool
  default = false
}

variable "encrypt_with_sqs_keys" {
  type        = bool
  description = "Encrypt the queue contents at rest with SQS encryption keys. "
  default     = true
}
