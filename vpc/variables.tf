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
