resource "aws_security_group" "security_group" {
  name        = var.name
  vpc_id      = var.vpc_id
  description = var.description
  tags = merge(
    var.common_tags,
    tomap(
      { "Name" = var.name }
    )
  )
}

resource "aws_vpc_security_group_egress_rule" "egress_rules" {
  count                        = length(var.rules.egress)
  ip_protocol                  = var.rules.egress[count.index].ip_protocol
  cidr_ipv4                    = var.rules.egress[count.index].cidr_ip_v4
  cidr_ipv6                    = var.rules.egress[count.index].cidr_ip_v6
  security_group_id            = aws_security_group.security_group.id
  referenced_security_group_id = var.rules.egress[count.index].security_group_id
  prefix_list_id               = var.rules.egress[count.index].prefix_list_id
  from_port                    = var.rules.egress[count.index].port
  to_port                      = var.rules.egress[count.index].port
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rules" {
  count                        = length(var.rules.ingress)
  ip_protocol                  = var.rules.ingress[count.index].ip_protocol
  cidr_ipv4                    = var.rules.ingress[count.index].cidr_ip_v4
  cidr_ipv6                    = var.rules.ingress[count.index].cidr_ip_v6
  security_group_id            = aws_security_group.security_group.id
  referenced_security_group_id = var.rules.ingress[count.index].security_group_id
  prefix_list_id               = var.rules.ingress[count.index].prefix_list_id
  from_port                    = var.rules.ingress[count.index].port
  to_port                      = var.rules.ingress[count.index].port
}

