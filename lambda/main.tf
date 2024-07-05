locals {
  sqs_mapping_without_ignore_enabled = { for mapping in var.lambda_sqs_queue_mappings : (mapping.sqs_queue_arn) => mapping.sqs_queue_concurrency if mapping.ignore_enabled_status == false }
  sqs_mapping_ignore_enabled         = { for mapping in var.lambda_sqs_queue_mappings : (mapping.sqs_queue_arn) => mapping.sqs_queue_concurrency if mapping.ignore_enabled_status == true }
}
resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name
  handler       = var.handler
  role          = aws_iam_role.lambda_iam_role.arn
  image_uri     = var.use_image ? null : var.image_url
  runtime       = var.use_image ? null : var.runtime
  filename      = var.use_image ? null : var.filename == "" ? startswith(var.runtime, "java") ? "${path.module}/functions/generic.jar" : "${path.module}/functions/generic.zip" : var.filename
  timeout       = var.timeout_seconds
  memory_size   = var.memory_size

  ephemeral_storage {
    size = var.storage_size
  }

  reserved_concurrent_executions = var.reserved_concurrency
  tags                           = var.tags
  environment {
    variables = local.all_env_vars
  }

  dynamic "file_system_config" {
    for_each = var.efs_access_points
    content {
      arn              = file_system_config.value.access_point_arn
      local_mount_path = file_system_config.value.mount_path
    }
  }
  vpc_config {
    security_group_ids = var.vpc_config.security_group_ids
    subnet_ids         = var.vpc_config.subnet_ids
  }

  lifecycle {
    ignore_changes = [filename]
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = var.log_retention
  kms_key_id        = var.log_group_kms_key_arn
  tags              = var.tags
}

locals {
  encrypted_env_vars      = { for k, v in var.encrypted_env_vars : k => aws_kms_ciphertext.encrypted_environment_variables[k].ciphertext_blob }
  all_env_vars            = merge(local.encrypted_env_vars, var.plaintext_env_vars)
  vpc_config_policy_count = var.vpc_config.subnet_ids == [] ? 0 : 1
}

resource "aws_kms_ciphertext" "encrypted_environment_variables" {
  for_each  = var.encrypted_env_vars
  key_id    = var.environment_variables_kms_key_arn
  plaintext = each.value
  context   = { "LambdaFunctionName" = var.function_name }
}

resource "aws_lambda_event_source_mapping" "sqs_queue_mappings" {
  for_each                           = local.sqs_mapping_without_ignore_enabled
  event_source_arn                   = each.key
  function_name                      = aws_lambda_function.lambda_function.*.arn[0]
  batch_size                         = var.sqs_queue_mapping_batch_size
  maximum_batching_window_in_seconds = var.sqs_queue_batching_window
  dynamic "scaling_config" {
    for_each = each.value == null ? [] : [each.value]
    content {
      maximum_concurrency = each.value
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_queue_mappings_ignore_enabled" {
  for_each                           = local.sqs_mapping_ignore_enabled
  event_source_arn                   = each.key
  function_name                      = aws_lambda_function.lambda_function.*.arn[0]
  batch_size                         = var.sqs_queue_mapping_batch_size
  maximum_batching_window_in_seconds = var.sqs_queue_batching_window
  dynamic "scaling_config" {
    for_each = each.value == null ? [] : [each.value]
    content {
      maximum_concurrency = each.value
    }
  }
  lifecycle {
    ignore_changes = [enabled]
  }
}

resource "aws_lambda_permission" "lambda_permissions" {
  for_each      = var.lambda_invoke_permissions
  statement_id  = "AllowExecutionFrom${title(split(".", each.key)[0])}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = each.key
  source_arn    = each.value
}

resource "aws_iam_role" "lambda_iam_role" {
  assume_role_policy = templatefile("${path.module}/templates/lambda_assume_role.json.tpl", {})
  name               = "${var.function_name}-role"
}

resource "aws_iam_policy" "lambda_policies" {
  for_each = var.policies
  policy   = each.value
  name     = each.key
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  for_each   = aws_iam_policy.lambda_policies
  policy_arn = each.value.arn
  role       = aws_iam_role.lambda_iam_role.name
}

resource "aws_iam_role_policy_attachment" "existing_policy_attachment" {
  for_each   = var.policy_attachments
  policy_arn = each.value
  role       = aws_iam_role.lambda_iam_role.name
}

resource "aws_iam_policy" "vpc_access_policy" {
  count       = local.vpc_config_policy_count
  policy      = templatefile("${path.module}/templates/lambda_vpc_policy.json.tpl", {})
  name        = "${var.function_name}-vpc-policy"
  description = "Allows access to the VPC for function ${var.function_name}"
}

resource "aws_iam_role_policy_attachment" "vpc_access_policy_attachment" {
  count      = local.vpc_config_policy_count
  policy_arn = aws_iam_policy.vpc_access_policy[count.index].arn
  role       = aws_iam_role.lambda_iam_role.name
}
