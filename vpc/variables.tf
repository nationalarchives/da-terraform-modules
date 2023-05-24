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
