variable "queue_name" {}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "sqs_policy" {
  description = "A string containing the SQS policy"
}

variable "redrive_maximum_receives" {
  default = 10
}

variable "visibility_timeout" {
  default = 30
}

variable "kms_key_id" {
  default = null
}

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
