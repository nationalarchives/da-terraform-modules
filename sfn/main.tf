resource "aws_sfn_state_machine" "step_function" {
  name       = var.step_function_name
  definition = var.step_function_definition
  role_arn   = module.step_function_role.role_arn
}

module "step_function_role" {
  source             = "../iam_role"
  assume_role_policy = templatefile("${path.module}/templates/sfn_assume_role.json.tpl", {})
  name               = "${var.step_function_name}-role"
  tags               = {}
  policy_attachments = var.step_function_role_policy_attachments
}
