output "params" {
  value = merge(aws_ssm_parameter.ssm_parameter, aws_ssm_parameter.ssm_parameter_ignore_value)
  param_arn = aws_ssm_parameter.ssm_parameter.arn
}
