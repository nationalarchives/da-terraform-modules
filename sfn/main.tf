resource "aws_sfn_state_machine" "step_function" {
  name       = var.step_function_name
  definition = var.step_function_definition
  role_arn   = module.step_function_role.role_arn
  tags       = var.common_tags
}

module "step_function_role" {
  source             = "../iam_role"
  assume_role_policy = data.aws_iam_policy_document.step_function_iam_trust_policy.json
  name               = "${var.step_function_name}-role"
  tags               = var.common_tags
  policy_attachments = var.step_function_role_policy_attachments
}

// See https://docs.aws.amazon.com/step-functions/latest/dg/procedure-create-iam-role.html
// Using a map run does not seem to be compatible with the aws:SourceArn
// Note using aws_sfn_state_machine.step_funcion.arn creates a cyclic dependancy so cannot be used
data "aws_iam_policy_document" "step_function_iam_trust_policy" {
  statement {

    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["${data.aws_caller_identity.current.id}"]
    }
  }
}
