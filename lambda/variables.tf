variable "function_name" {
  description = "The name of the lambda function"
}

variable "handler" {
  description = "The lambda function handler"
}

variable "environment_variables_kms_key_arn" {
  description = "The kms key to use to encrypt environment variables if necessary"
  default     = null
}

variable "encrypted_env_vars" {
  default     = {}
  type        = map(string)
  description = "A map of environment variables in the form ENV_VAR_NAME -> plaintext value These will be encrypted"
}

variable "plaintext_env_vars" {
  default     = {}
  type        = map(string)
  description = "A map of environment variables in the form ENV_VAR_NAME -> plaintext value These will not be encrypted"
}

variable "runtime" {
  description = "The lambda runtime, for example java11"
}

variable "timeout_seconds" {
  default = 15
}

variable "memory_size" {
  default = 256
}

variable "reserved_concurrency" {
  default = -1
}

variable "tags" {
  type = map(string)
}

variable "efs_access_points" {
  type = list(object({
    access_point_arn = string,
    mount_path       = string
  }))
  default     = []
  description = "A list of access point arns and mount paths. This can be omitted if EFS is not needed"
}

variable "vpc_config" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = {
    subnet_ids         = [],
    security_group_ids = []
  }
}

variable "log_group_kms_key_arn" {
  description = "A kms key arn to encrypt the lambda log group with"
  default     = null
}

variable "lambda_sqs_queue_mappings" {
  type = list(object({
    sqs_queue_arn         = string
    sqs_queue_concurrency = optional(number, null)
    ignore_enabled_status = optional(bool, false)
  }))
  default     = []
  description = <<EOT
    A list of objects to create SQS queue mappings
    sqs_queue_arn: The queue arn to map to the lambda
    sqs_queue_concurrency: The concurrency of the queue mapping
    ignore_enabled_status: Whether to ignore the status of the mapping. This is useful if you want to disable the mapping
    manually without terraform overwriting it.
  EOT
}

variable "storage_size" {
  default     = 512
  description = "The amount of disk storage available in the lambdas /tmp directory"
}

variable "lambda_invoke_permissions" {
  description = "A list of principals and source arns to be allowed to call lambda:InvokeFunction"
  type        = map(string)
  default     = {}
}

variable "policies" {
  description = "A map in the form policyName -> policyBodyString"
  type        = map(string)
}

variable "policy_attachments" {
  type        = set(string)
  default     = []
  description = "A list of policy arns to attach. These will need to be pre-existing policies"
}

variable "log_retention" {
  default = 30
}

variable "sqs_queue_mapping_batch_size" {
  default = 1
}

variable "sqs_queue_batching_window" {
  default = 0
}

variable "filename" {
  description = "Allows a filename to be passed directly to the module instead of using the generic ones"
  default     = ""
}
