variable "topic_name" {}

variable "tags" {
  description = "tags used across the project"
}

variable "sns_policy" {
  description = "A string containing the SNS policy"
}

variable "kms_key_arn" {
  description = "A KMS key arn to be used to encrypt the queue contents at rest"
}

variable "lambda_subscriptions" {
  type        = map(string)
  description = "A map of lambda names to arns to subscribe to this topic"
  default     = {}
}

variable "sqs_subscriptions" {
  type        = map(string)
  description = "A map of SQS names to arns to subscribe to this topic"
  default     = {}
}
