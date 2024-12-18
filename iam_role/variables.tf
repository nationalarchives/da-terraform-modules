variable "assume_role_policy" {
  description = "A string containing the assume role policy"
}

variable "name" {}

variable "policy_attachments" {
  description = "A list of policy arns to attach to the role"
  type        = map(string)
}

variable "tags" {
  description = "A list of tags to apply to the resource"
  type        = map(string)
}

variable "permissions_boundary" {
  description = "Permissions boundary to attach to the role"
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "The maximum session duration for the role. Defaults to 1 hour"
  default     = 3600
  type        = number
}
