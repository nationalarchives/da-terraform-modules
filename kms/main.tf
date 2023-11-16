data "aws_caller_identity" "current" {}

resource "aws_kms_key" "encryption" {
  description         = var.key_description
  enable_key_rotation = true
  policy              = var.key_policy == "" ? data.aws_iam_policy_document.key_policy.json : var.key_policy
  permissions_boundary = var.permissions_boundary
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
      { "Name" = "${var.key_name}-admin", "Type" = "kms-admin-role" }
    )
  )
}

data "aws_iam_policy_document" "key_policy" {
  statement {
    sid = "RootUserAllowAll"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      values   = ["Account"]
      variable = "aws:PrincipalType"
    }
  }
  statement {
    sid = "AccountRootDescribeKey"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:DescribeKey", "kms:GetKeyPolicy"]
    resources = ["*"]
  }
  statement {
    sid = "AdminRoleAdministerKey"
    principals {
      type        = "AWS"
      identifiers = [module.kms_admin_role.role_arn]
    }
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
  }
  dynamic "statement" {
    for_each = length(var.default_policy_variables.ci_roles) == 0 ? [] : ["ci_roles"]
    content {
      sid = "CIRolesAdministerWithoutDelete"
      principals {
        type        = "AWS"
        identifiers = var.default_policy_variables.ci_roles
      }
      actions = [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:TagResource",
        "kms:UntagResource"
      ]
      resources = ["*"]
    }
  }
  dynamic "statement" {
    for_each = length(var.default_policy_variables.user_roles) == 0 ? [] : ["user_roles"]
    content {
      sid = "UserRolesEncryptAndDecrypt"
      principals {
        type        = "AWS"
        identifiers = var.default_policy_variables.user_roles
      }
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
    }
  }
  dynamic "statement" {
    for_each = length(var.default_policy_variables.persistent_resource_roles) == 0 ? [] : ["persistent_resource_roles"]
    content {
      sid = "ResourceRolesGrants"
      principals {
        type        = "AWS"
        identifiers = var.default_policy_variables.persistent_resource_roles
      }
      actions = [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ]
      resources = ["*"]
      condition {
        test     = "Bool"
        values   = ["kms:GrantIsForAWSResource"]
        variable = "true"
      }
    }
  }
  dynamic "statement" {
    for_each = var.default_policy_variables.service_names
    content {
      sid = "AllowSameAccountServiceAccess${title(statement.value)}"
      principals {
        type        = "Service"
        identifiers = ["${statement.value}.amazonaws.com"]
      }
      actions = startswith(statement.value, "logs.") ? [
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
        ] : [
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      effect    = "Allow"
      resources = ["*"]
      condition {
        test     = "StringEquals"
        values   = [var.default_policy_variables.service_source_account == "" ? data.aws_caller_identity.current.account_id : var.default_policy_variables.service_source_account]
        variable = "aws:SourceAccount"
      }
    }
  }
}
