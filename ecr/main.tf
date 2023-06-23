resource "aws_ecr_repository" "ecr_repository" {
  name                 = var.name
  image_tag_mutability = var.tag_mutability

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

resource "aws_ecr_repository_policy" "ecr_repository_policy" {
  count      = var.policy == "" ? 0 : 1
  policy     = var.policy
  repository = aws_ecr_repository.ecr_repository.name
}

resource "aws_ecr_lifecycle_policy" "remove_untagged_images" {
  policy     = var.life_cycle_policy
  repository = aws_ecr_repository.ecr_repository.name
}
