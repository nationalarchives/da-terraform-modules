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

variable "queue_cloudwatch_alarm_visible_messages_threshold" {
  description = "The alarm will alert if ApproximateNumberOfMessagesVisible is above this threshold for the queue"
  default     = 10
}

variable "dlq_cloudwatch_alarm_visible_messages_threshold" {
  description = "The alarm will alert if ApproximateNumberOfMessagesVisible is above this threshold for the dlq"
  default     = 0
}

variable "encryption_type" {
  default = "kms"
  validation {
    condition     = contains(["sse", "kms"], var.encryption_type)
    error_message = "You must select either sse or kms encryption"
  }
}

variable "create_dlq" {
  type    = bool
  default = false
}

variable "dlq_notification_topic" {
  description = "A topic arn which will be used to send ALARM events if a message is put into the DLQ and OK events when it is removed."
  default     = null
}

variable "queue_visibility_alarm_notification_topic" {
  description = "A topic arn which will be used to send ALARM events if the alarm for max number of messages in the queue is triggered."
  default     = null
}

variable "dlq_alarm_messages_visible_period" {
  type        = number
  description = "The period for the metrics for the DLQ alarm visible messages"
  default     = 60
}

variable "messages_visible_alarm_period" {
  type        = number
  description = "The period for the metrics for the alarm visible messages"
  default     = 900
}
