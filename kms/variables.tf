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
  ci_roles - Roles to be run by terraform. They have access to administer the key but not decrypt or delete.
  persistent_resource_roles - A list of roles which will allow those roles to grant access to AWS services. See   https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-service-integration for more information.
  service_details - A list of service_detail objects, with a service name and a source account to add to the policy condition. This will allow decryption from AWS services.
  wiz_roles - A list of wiz access roles to allow for full scanning of AWS resources for issues.
  EOT
  type = object({
    user_roles                = optional(list(string), [])
    ci_roles                  = optional(list(string), [])
    persistent_resource_roles = optional(list(string), [])
    service_details = optional(list(object({
      service_name           = string
      service_source_account = optional(string, null)
    })), [])
    cloudfront_distributions = optional(list(string), [])
    wiz_roles                = optional(list(string), [])
  })
  default = {
    user_roles                = []
    persistent_resource_roles = []
    ci_roles                  = []
    service_details           = []
    cloudfront_distributions  = []
    wiz_roles                 = []
  }
}

variable "permissions_boundary" {
  description = "Permissions boundary to attach to the role"
  type        = string
  default     = null
}

variable "environment" {
  default = ""
}

