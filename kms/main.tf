data "aws_caller_identity" "current" {}

resource "aws_kms_key" "encryption" {
  description         = var.key_description
  enable_key_rotation = true
  policy = var.key_policy == "" ? templatefile("${path.module}/templates/default_key_policy.json.tpl", {
    admin_role_arn            = module.kms_admin_role.role_arn
    account_id                = data.aws_caller_identity.current.account_id
    user_roles                = jsonencode(var.default_policy_variables.user_roles)
    persistent_resource_roles = jsonencode(var.default_policy_variables.persistent_resource_roles)
  }) : var.key_policy
  tags = merge(
    var.tags,
    tomap(
      { "Name" = var.key_name }
    )
  )
}

resource "aws_kms_alias" "encryption" {
  name          = "alias/${var.key_name}"
  target_key_id = aws_kms_key.encryption.key_id
}

module "kms_admin_role" {
  source             = "../iam_role"
  assume_role_policy = templatefile("${path.module}/templates/deny_all.json.tpl", {})
  name               = "${var.key_name}-admin"
  policy_attachments = {
    kms_power_user = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
  }
  tags = merge(
    var.tags,
    tomap(
      { "Name" = "${var.key_name}-admin" }
    )
  )
}
