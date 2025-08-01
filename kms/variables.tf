variable "key_name" {}

variable "key_policy" {
  default = ""
}

variable "tags" {
  default = {}
}

variable "key_description" {
  default = ""
}

variable "default_policy_variables" {
  description = <<EOT
  Policy variables for the default KMS policy
  user_roles - A list of roles which will have access to encrypt and decrypt with the key
  user_roles_decoupled - A list of roles which will have access to encrypt and decrypt with the key. Unlike user_roles these will be added as a condition instead of a principal to the statement, meaning that KMS will not resolve these ARNs to unique role IDs within AWS - they will be treated as strings. These principals MUST be within the same AWS Organization as the key.
  ci_roles - Roles to be run by terraform. They have access to administer the key but not decrypt or delete.
  persistent_resource_roles - A list of roles which will allow those roles to grant access to AWS services. See   https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-service-integration for more information.
  persistent_resource_roles_decoupled - A list of roles which will allow those roles to grant access to AWS services. Unlike persistent_resource_roles these will be added as a condition instead of a principal to the statement, meaning that KMS will not resolve these ARNs to unique role IDs within AWS - they will be treated as strings. These principals MUST be within the same AWS Organization as the key.
  service_details - A list of service_detail objects, with a service name and a source account to add to the policy condition. This will allow decryption from AWS services.
  wiz_roles - A list of wiz access roles to allow for full scanning of AWS resources for issues. DEPRECATED: Use user_roles_decoupled and persistent_resource_roles_decoupled instead
  EOT
  type = object({
    user_roles                          = optional(list(string), [])
    user_roles_decoupled                = optional(list(string), []) # Prefer user_roles where possible, this is for specific cross-account access where the principal may not exist when deploying. Review use with Technical Architects.
    ci_roles                            = optional(list(string), [])
    persistent_resource_roles           = optional(list(string), []) # Prefer persistent_resource_roles where possible, this is for specific cross-account access where the principal may not exist when deploying. Review use with Technical Architects.
    persistent_resource_roles_decoupled = optional(list(string), [])
    service_details = optional(list(object({
      service_name           = string
      service_source_account = optional(string, null)
    })), [])
    cloudfront_distributions = optional(list(string), [])
    wiz_roles                = optional(list(string), []) # DEPRECATED: Use user_roles_decoupled and persistent_resource_roles_decoupled instead
  })
  default = {
    user_roles                          = []
    user_roles_decoupled                = []
    persistent_resource_roles           = []
    persistent_resource_roles_decoupled = []
    ci_roles                            = []
    service_details                     = []
    cloudfront_distributions            = []
    wiz_roles                           = []
  }
}

variable "permissions_boundary" {
  description = "Permissions boundary to attach to the role"
  type        = string
  default     = null
}
