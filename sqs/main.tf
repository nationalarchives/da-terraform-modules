locals {
  queue_name_suffix = var.fifo_queue ? ".fifo" : ""
  sqs_queue         = var.encryption_type == "sse" ? aws_sqs_queue.sqs_queue_with_sse[0] : aws_sqs_queue.sqs_queue_with_kms[0]
  sqs_dlq           = var.encryption_type == "sse" ? aws_sqs_queue.dlq_with_sse[0] : aws_sqs_queue.dlq_with_kms[0]
}

resource "aws_sqs_queue" "sqs_queue_with_sse" {
  count                     = var.encryption_type == "sse" ? 1 : 0
  name                      = "${var.queue_name}${local.queue_name_suffix}"
  delay_seconds             = var.delay_seconds
  fifo_queue                = var.fifo_queue
  sqs_managed_sse_enabled   = true
  message_retention_seconds = var.message_retention_seconds
  max_message_size          = var.max_message_size
  policy                    = var.sqs_policy
  receive_wait_time_seconds = var.receive_wait_time_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq_with_sse[count.index].arn
    maxReceiveCount     = var.redrive_maximum_receives
  })
  tags = merge(
    var.tags,
    tomap(
      { Name = var.queue_name }
    )
  )
  visibility_timeout_seconds = var.visibility_timeout
}

resource "aws_sqs_queue" "sqs_queue_with_kms" {
  count                     = var.encryption_type == "sse" ? 0 : 1
  name                      = "${var.queue_name}${local.queue_name_suffix}"
  delay_seconds             = var.delay_seconds
  fifo_queue                = var.fifo_queue
  kms_master_key_id         = var.kms_key_id
  message_retention_seconds = var.message_retention_seconds
  max_message_size          = var.max_message_size
  policy                    = var.sqs_policy
  receive_wait_time_seconds = var.receive_wait_time_seconds
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq_with_kms[count.index].arn
    maxReceiveCount     = var.redrive_maximum_receives
  })
  tags = merge(
    var.tags,
    tomap(
      { Name = var.queue_name }
    )
  )
  visibility_timeout_seconds = var.visibility_timeout
}

resource "aws_sqs_queue" "dlq_with_kms" {
  count                     = var.encryption_type == "sse" ? 0 : 1
  name                      = "${var.queue_name}-dlq"
  message_retention_seconds = 1209600
  kms_master_key_id         = var.kms_key_id
}

resource "aws_sqs_queue" "dlq_with_sse" {
  count                     = var.encryption_type == "sse" ? 1 : 0
  name                      = "${var.queue_name}-dlq"
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true
}

module "dlq_cloudwatch_alarm" {
  source              = "../cloudwatch_alarms"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  name                = "${var.queue_name}-dlq-alarm"
  threshold           = var.dlq_cloudwatch_alarm_visible_messages_threshold
  comparison_operator = "GreaterThanThreshold"
  statistic           = "Sum"
  treat_missing_data  = "ignore"
  datapoints_to_alarm = 1
  dimensions = {
    QueueName = local.sqs_dlq.name
  }
  notification_topic = var.dlq_notification_topic
}

module "queue_cloudwatch_alarm" {
  source              = "../cloudwatch_alarms"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  name                = "${var.queue_name}-messages-visible-alarm"
  threshold           = var.queue_cloudwatch_alarm_visible_messages_threshold
  comparison_operator = "GreaterThanThreshold"
  statistic           = "Sum"
  treat_missing_data  = "ignore"
  datapoints_to_alarm = 1
  dimensions = {
    QueueName = local.sqs_queue.name
  }
  notification_topic = var.queue_visibility_alarm_notification_topic
}
