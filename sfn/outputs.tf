output "step_function_arn" {
  value = aws_sfn_state_machine.step_function.arn
}

output "step_function_role_arn" {
  value = module.step_function_role.role_arn
}
