variable "event_pattern" {
  default     = ""
  description = "A string defining the event pattern for the rule. Cannot be used with schedule"
}

# DEPRECATED: Please specify target arns within target agnostic `event_target_arns` map moving forward
variable "sqs_event_target_arn" {
  description = "An SQS queue ARN to attach to the event"
  default     = ""
}

# DEPRECATED: Please supply target arns within target agnostic `event_target_arns` map moving forward
variable "lambda_event_target_arn" {
  description = "A Lambda ARN to attach to the event"
  type        = string
  default     = ""
}

# DEPRECATED: Please supply target arns within target agnostic `event_target_arns` map moving forward
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

variable "event_target_arns" {
  description = "Name to arn map for the event target resources"
  type = map(string)
  default = {}
}
