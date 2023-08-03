variable "step_function_name" {}

variable "step_function_definition" {
  description = "A json string containing the step function definition"
}

variable "step_function_role_policy_attachments" {
  description = "A list of policy arns to attach to the step function role"
  type        = map(string)
}
