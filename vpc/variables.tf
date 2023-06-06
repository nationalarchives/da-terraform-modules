variable "vpc_name" {
  type = string
}

variable "az_count" {
  type    = number
  default = 2
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr_prefix" {
  default     = "/24"
  description = "The cidr prefix to determine the subnet sizes"
}

variable "create_nat_gateway" {
  default = false
}

variable "elastic_ip_ids" {
  description = "A list of elastic IPs to assign to the NAT gateway or the NAT instance"
  type        = list(string)
  default     = []
}

variable "nat_instance_settings" {
  type = object({
    security_group                = string
    nat_instance_type             = optional(string, "t4g.nano")
    nat_instance_iam_profile_name = optional(string)
    nat_instance_iam_role_name    = optional(string)
  })
}

variable "enable_dns_hostnames" {
  default = true
}

variable "enable_dns_support" {
  default = true
}
