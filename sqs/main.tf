resource "aws_sqs_queue" "sqs_queue" {
  name                      = var.queue_name
  delay_seconds             = var.delay_seconds
  fifo_queue                = var.fifo_queue
  kms_master_key_id         = var.kms_key_id != "" ? var.kms_key_id : null
  message_retention_seconds = var.message_retention_seconds
  max_message_size          = var.max_message_size
  policy                    = var.sqs_policy
  receive_wait_time_seconds = var.receive_wait_time_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.redrive_maximum_receives
  })
  sqs_managed_sse_enabled = var.encrypt_with_sqs_keys
  tags = merge(
    var.tags,
    tomap(
      { Name = var.queue_name }
    )
  )
  visibility_timeout_seconds = var.visibility_timeout
}

resource "aws_sqs_queue" "dlq" {
  name = "${var.queue_name}-dlq"
}
