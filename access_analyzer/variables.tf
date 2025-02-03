variable "access_analyzer_name" {
  description = "Name of the AWS Access Analyzer instance"
  type        = string
}

variable "access_analyzer_type" {
  description = "Type of Access Analyzer"
  type        = string
}

variable "unused_access_age" {
  description = "The number of days before access is considered unused for"
  type        = number
  default     = 90
}

variable "create_archive_rule" {
  description = "Flag to determine whether an archive rule should be created."
  type        = bool
  default     = false
}

variable "archive_rule_name" {
  description = "The name of the archive rule for AWS Access Analyzer."
  type        = string
  default     = null
}

variable "criteria" {
  description = "Map of filter criteria for Access Analyzer archive rule, with supported comparators."
  type = map(object({
    contains = optional(list(string))
    eq       = optional(list(string))
    exists   = optional(bool)
    neq      = optional(list(string))
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to assign to the AWS Access Analyzer."
  type        = map(string)
  default     = {}
}
