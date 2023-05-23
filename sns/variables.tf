variable "topic_name" {}

variable "tags" {
  description = "tags used across the project"
}

variable "sns_policy" {
  description = "A string containing the SNS policy"
}

variable "kms_key_arn" {
  description = "A KMS key arn to be used to encrypt the queue contents at rest"
  default     = ""
}

variable "lambda_subscriptions" {
  type        = list(string)
  description = "A list of lambda arns to subscribe to this topic"
}

variable "sqs_subscriptions" {
  type        = list(string)
  description = "A list of SQS arns to subscribe to this topic"
}
