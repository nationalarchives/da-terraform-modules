variable "vpc_id" {}

variable "name" {}

variable "description" {}


variable "rules" {
  type = object({
    ingress = optional(list(object({
      ip_protocol       = optional(string, "tcp")
      port              = number
      description       = string
      cidr_ip_v4        = optional(string)
      cidr_ip_v6        = optional(string)
      security_group_id = optional(string)
      prefix_list_id    = optional(string)
    })), [])
    egress = optional(list(object({
      ip_protocol       = optional(string, "tcp")
      port              = number
      description       = string
      cidr_ip_v4        = optional(string)
      cidr_ip_v6        = optional(string)
      security_group_id = optional(string)
      prefix_list_id    = optional(string)
    })), [])
  })
}
