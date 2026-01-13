variable "event_pattern" {
  default     = ""
  description = "A string defining the event pattern for the rule. Cannot be used with schedule"
}

variable "sqs_event_target_arn" {
  description = "An SQS queue ARN to attach to the event"
  default     = ""
}
variable "lambda_event_target_arn" {
  description = "A Lambda ARN to attach to the event"
  type        = string
  default     = ""
}

variable "sns_topic_event_target_arn" {
  description = "A SNS topic ARNs to attach to the event"
  type        = string
  default     = ""
}
variable "rule_name" {}

variable "rule_description" {
  default = ""
}

variable "schedule" {
  description = "The schedule for the event rule. Cannot be used with event pattern"
  default     = ""
}

variable "input" {
  description = "Static json input to pass to the event target"
  default     = ""
}
