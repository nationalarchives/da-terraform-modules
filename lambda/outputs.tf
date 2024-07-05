output "lambda_arn" {
  value = var.use_image ? aws_lambda_function.lambda_function[0].arn : aws_lambda_function.lambda_function_zip[0].arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_iam_role.arn
}
