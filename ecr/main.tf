data "aws_caller_identity" "current" {}

locals {
  allowed_principals       = var.allowed_principals == [] ? jsonencode([data.aws_caller_identity.current.account_id]) : jsonencode(var.allowed_principals)
  default_lifecycle_policy = templatefile("${path.module}/templates/expire_untagged_x_days.json.tpl", { expire_untagged_images_days = var.expire_untagged_images_days })
}

resource "aws_ecr_lifecycle_policy" "repository_policy" {
  policy     = var.lifecycle_policy == null ? local.default_lifecycle_policy : var.lifecycle_policy
  repository = aws_ecr_repository.repository.name
}

resource "aws_ecr_repository" "repository" {
  name = var.repository_name
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.common_tags,
    tomap(
      { "ImageSource" = var.image_source_url }
    )
  )
}

resource "aws_ecr_repository_policy" "repository_policy" {
  policy     = var.repository_policy == null ? templatefile("${path.module}/templates/default_policy.json.tpl", { allowed_principals = local.allowed_principals }) : var.repository_policy
  repository = aws_ecr_repository.repository.name
}
