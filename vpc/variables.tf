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

variable "use_nat_gateway" {
  description = "Will create a nat gateway if set to true and a nat instance otherwise"
  default     = false
}
