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

variable "new_bits" {
  default     = 8
  description = "The number of bits to extend the network prefix by when creating subnets. A /16 VPC CIDR block and a new_bits value of 8 will return a /24 subnet"
}

variable "elastic_ip_ids" {
  description = "A list of elastic IPs to assign to the NAT gateway if it is used. Can't be used with network_interface_ids"
  type        = list(string)
  default     = []
}

variable "network_interface_ids" {
  description = "A list of EC2 ENI ids to attach to a route table. Can't be used with elastic_ip_ids"
  type        = list(string)
  default     = []
}
