variable "vpc_id" {}

variable "name" {}

variable "description" {}

variable "ingress_cidr_rules" {
  type = set(object({
    port        = number
    description = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "ingress_security_group_rules" {
  type = set(object({
    port              = number
    description       = string
    security_group_id = string
  }))
  default = []
}

variable "egress_cidr_rules" {
  type = set(object({
    port        = number
    description = string
    cidr_blocks = list(string)
    protocol    = string
  }))
  default = []
}

variable "egress_security_group_rules" {
  type = set(object({
    port              = number
    description       = string
    security_group_id = string
    protocol          = string
  }))
  default = []
}

variable "ingress_prefix_list_rules" {
  type = set(object({
    port         = number
    description  = string
    prefix_lists = list(string)
  }))
  default = []
}

variable "egress_prefix_list_rules" {
  type = set(object({
    port            = number
    description     = string
    prefix_list_ids = list(string)
    protocol        = string
  }))
  default = []
}

variable "common_tags" {}
