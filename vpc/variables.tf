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
  description = "The cidr prefix to determine the subnet sizes"
  default     = "/24"
}

variable "elastic_ip_allocation_ids" {
  description = "A list of elastic IPs to assign to the NAT gateway if it is used."
  type        = list(string)
  default     = []
}

variable "nat_instance_security_groups" {
  description = "A list of security groups for the NAT instance"
  type        = list(string)
  default     = []
}

variable "nat_instance_type" {
  description = "The instance type for the NAT instance"
  default     = "t3.nano"
}

variable "use_nat_gateway" {
  description = "Will create a nat gateway if set to true and a nat instance otherwise"
  default     = false
}

variable "environment" {}

variable "private_nacl_rules" {
  type = set(object({
    rule_no    = number
    cidr_block = string
    action     = string
    from_port  = number
    to_port    = number
    egress     = bool
  }))
  default = []
}

variable "public_nacl_rules" {
  type = set(object({
    rule_no    = number
    cidr_block = string
    action     = string
    from_port  = number
    to_port    = number
    egress     = bool
  }))
  default = []
}

variable "create_s3_gateway_endpoint" {
  default = false
}

variable "create_dynamo_gateway_endpoint" {
  type    = bool
  default = false
}

variable "enable_dns_hostnames" {
  default = true
}

variable "enable_dns_support" {
  default = true
}

variable "region" {
  default = "eu-west-2"
}
