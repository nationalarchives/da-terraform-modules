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
  service_names - A list of service names, e.g cloudwatch, which will allow decryption from AWS services.
  EOT
  type = object({
    user_roles                = optional(list(string), [])
    ci_roles                  = optional(list(string), [])
    persistent_resource_roles = optional(list(string), [])
    service_names             = optional(list(string), [])
    service_source_account    = optional(string, "")
  })
  default = {
    user_roles                = []
    persistent_resource_roles = []
    ci_roles                  = []
    service_names             = []
    service_source_account    = ""
  }
}
