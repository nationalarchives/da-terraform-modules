variable "common_tags" {
  description = "Tags used across the project"
}

variable "hosted_zone_name" {
  description = "Name of the hosted zone"
}

variable "ns_ttl" {
  description = "time to live for name servers"
  default     = "172800"
}

variable "manual_creation" {
  description = "DNS zone created manually and imported to Terraform state"
  default     = false
}

variable "alb_dns_name" {
  description = "The DNS name for the target load balancer"
  default     = ""
}

variable "alb_zone_id" {
  description = "The zone for the target load balancer"
  default     = ""
}

variable "a_record_name" {
  description = "The name to use for the A record"
  default     = ""
}

variable "create_hosted_zone" {
  description = "Whether to create the hosted zone or not. Cases where hosted zone already created"
  default = true
}

variable "hosted_zone_id" {
  default = ""
}

variable "hosted_zone_name_servers" {
  default = ""
}
