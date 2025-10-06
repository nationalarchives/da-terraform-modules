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

resource "aws_security_group_rule" "ingress_cidr_rule" {
  for_each          = { for rule in var.ingress_cidr_rules : rule.description => rule }
  protocol          = "tcp"
  security_group_id = aws_security_group.security_group.id
  cidr_blocks       = each.value.cidr_blocks
  to_port           = each.value.port
  from_port         = each.value.port
  type              = "ingress"
}

resource "aws_security_group_rule" "ingress_security_group_rule" {
  for_each                 = { for rule in var.ingress_security_group_rules : rule.description => rule }
  protocol                 = "tcp"
  security_group_id        = aws_security_group.security_group.id
  source_security_group_id = each.value.security_group_id
  to_port                  = each.value.port
  from_port                = each.value.port
  type                     = "ingress"
}

resource "aws_security_group_rule" "egress_cidr_rule" {
  for_each          = { for rule in var.egress_cidr_rules : rule.description => rule }
  protocol          = each.value.protocol
  security_group_id = aws_security_group.security_group.id
  cidr_blocks       = each.value.cidr_blocks
  to_port           = each.value.port
  from_port         = each.value.port
  type              = "egress"
}

resource "aws_security_group_rule" "egress_security_group_rule" {
  for_each                 = { for rule in var.egress_security_group_rules : rule.description => rule }
  protocol                 = "tcp"
  security_group_id        = aws_security_group.security_group.id
  source_security_group_id = each.value.security_group_id
  to_port                  = each.value.port
  from_port                = each.value.port
  type                     = "egress"
}

resource "aws_security_group_rule" "ingress_prefix_list_rule" {
  for_each          = { for rule in var.ingress_prefix_list_rules : rule.description => rule }
  protocol          = "tcp"
  security_group_id = aws_security_group.security_group.id
  prefix_list_ids   = each.value.prefix_lists
  to_port           = each.value.port
  from_port         = each.value.port
  type              = "ingress"
}

resource "aws_security_group_rule" "egress_prefix_list_rule" {
  for_each          = { for rule in var.egress_prefix_list_rules : rule.description => rule }
  protocol          = each.value.protocol
  security_group_id = aws_security_group.security_group.id
  prefix_list_ids   = each.value.prefix_list_ids
  to_port           = each.value.port
  from_port         = each.value.port
  type              = "egress"
}