resource "aws_iam_role" "iam_role" {
  assume_role_policy   = var.assume_role_policy
  name                 = var.name
  permissions_boundary = var.permissions_boundary
  max_session_duration = var.max_session_duration
  tags = merge(
    var.tags,
    tomap(
      { Name = var.name }
    )
  )
}

resource "aws_iam_role_policy_attachment" "role_policy_attachments" {
  for_each   = var.policy_attachments
  policy_arn = each.value
  role       = aws_iam_role.iam_role.id
}
