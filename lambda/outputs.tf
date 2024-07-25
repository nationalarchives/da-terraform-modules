output "lambda_arn" {
  value = local.lambda_arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_iam_role.arn
}
