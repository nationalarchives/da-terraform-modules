variable "trust_anchor_arn" {
  type        = string
  description = "arn of an existing anchor to use which isn't managed by this module, instead of creating the default ds-ca-prod one"
  default     = null
}

variable "x509_cert_location" {
  type        = string
  description = "http(s) location of certificate bundle to use for trust anchor.  Ignored if trust_anchor_arn specified"
  # if your terraform plan is constantly bringing up the pem as a change, make sure it has a trailing newline at the end
  default = "https://certs.nationalarchives.gov.uk/serverless-ca-bundle.pem"
}

variable "roles" {
  type = map(object({
    x509_subject_cn      = string
    x509_subject_ou      = optional(string, "Digital Archiving")
    policy_attachments   = optional(map(string), {})
    tags                 = optional(map(string), {})
    permissions_boundary = optional(string)
    max_session_duration = optional(number)
    allowed_subnets      = optional(map(string))
  }))
  description = "roles to create, with subject CN and OU for identifying the role assumer. See iam_role module for details on the rest"
}