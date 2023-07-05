variable "thumbprint" {
  description = "The thumbprint for the OIDC provider. These are public"
}

variable "audience" {
  description = "The audience for the OIDC provider"
}

variable "url" {
  description = "The url for the OIDC provider"
}

variable "tags" {
  description = "A list of tags to apply to the resource"
  type        = map(string)
}
