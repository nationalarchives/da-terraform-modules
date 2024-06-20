variable "project" {
  description = "Abbreviation for the project, e.g. tdr, forms the first part of the resource name"
}

variable "function" {
  description = "forms the second part of the certificate name, eg. jenkins"
}

variable "common_tags" {
  description = "Tags used across the project"
}

variable "dns_zone" {
  description = "DNS zone domain, e.g. example.com"
}

variable "domain_name" {
  description = "Domain name to include in certificate, e.g. app.example.com"
}

variable "environment" {
  description = "Name of the project environment, eg prod"
}
