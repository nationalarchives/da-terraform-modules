locals {
  queue_name_suffix = var.fifo_queue ? ".fifo" : ""
  queue_name        = "${var.queue_name}${local.queue_name_suffix}"
  dlq_queue_name    = "${var.queue_name}-dlq${local.queue_name_suffix}"
  sqs_queue         = var.encryption_type == "sse" ? aws_sqs_queue.sqs_queue_with_sse[0] : aws_sqs_queue.sqs_queue_with_kms[0]
  sqs_dlq           = var.encryption_type == "sse" ? aws_sqs_queue.dlq_with_sse[0] : aws_sqs_queue.dlq_with_kms[0]
}

resource "aws_sqs_queue" "sqs_queue_with_sse" {
  count                     = var.encryption_type == "sse" ? 1 : 0
  name                      = local.queue_name
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
      { Name = local.queue_name }
    )
  )
  visibility_timeout_seconds = var.visibility_timeout
}

resource "aws_sqs_queue" "sqs_queue_with_kms" {
  count                     = var.encryption_type == "sse" ? 0 : 1
  name                      = local.queue_name
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
      { Name = local.queue_name }
    )
  )
  visibility_timeout_seconds = var.visibility_timeout
}

resource "aws_sqs_queue" "dlq_with_kms" {
  count                     = var.encryption_type == "sse" ? 0 : 1
  name                      = local.dlq_queue_name
  fifo_queue                = var.fifo_queue
  message_retention_seconds = 1209600
  kms_master_key_id         = var.kms_key_id
}

resource "aws_sqs_queue" "dlq_with_sse" {
  count                     = var.encryption_type == "sse" ? 1 : 0
  name                      = local.dlq_queue_name
  fifo_queue                = var.fifo_queue
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true
}


module "dlq_metric_messages_visible_alarm" {
  source              = "../cloudwatch_alarms"
  name                = "${local.dlq_queue_name}-messages-visible-alarm"
  comparison_operator = "GreaterThanThreshold"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  statistic           = "Sum"
  treat_missing_data  = "ignore"
  datapoints_to_alarm = 1
  dimensions = {
    QueueName = local.dlq_queue_name
  }
  period    = var.dlq_alarm_messages_visible_period
  threshold = var.dlq_cloudwatch_alarm_visible_messages_threshold
}

module "queue_cloudwatch_alarm" {
  source              = "../cloudwatch_alarms"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  name                = "${local.queue_name}-messages-visible-alarm"
  threshold           = var.queue_cloudwatch_alarm_visible_messages_threshold
  comparison_operator = "GreaterThanThreshold"
  statistic           = "Sum"
  treat_missing_data  = "ignore"
  datapoints_to_alarm = 1
  dimensions = {
    QueueName = local.queue_name
  }
  notification_topic = var.queue_visibility_alarm_notification_topic
}

resource "aws_cloudwatch_metric_alarm" "new_messages_added_to_dlq_alert" {
  alarm_name          = "${local.sqs_dlq.name}-new-messages-added-alarm"
  alarm_description   = "Triggers when number of messages compared to the previous N mins has increased"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  datapoints_to_alarm = 1

  metric_query {
    id = "m1"
    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      stat        = "Maximum"
      period      = 60
      namespace   = "AWS/SQS"
      dimensions = {
        QueueName = local.sqs_dlq.name
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "ApproximateNumberOfMessagesNotVisible"
      stat        = "Maximum"
      period      = 60
      namespace   = "AWS/SQS"
      dimensions = {
        QueueName = local.sqs_dlq.name
      }
    }
  }

  metric_query {
    id          = "e1"
    expression  = "DIFF(m1 + m2)"
    label       = "NewMessagesInQueue"
    return_data = true
  }
}

resource "aws_cloudwatch_metric_alarm" "unprocessed_messages_alert" {
  for_each            = toset([local.sqs_dlq.name, local.sqs_queue.name])
  alarm_name          = "${each.key}-unprocessed-messages-alert"
  alarm_description   = "Triggers when there are messages in the queue but no messages have been recieved for specified period"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 0
  datapoints_to_alarm = 1

  metric_query {
    id = "m1"
    metric {
      metric_name = "ApproximateNumberOfMessagesVisible"
      stat        = "Sum"
      period      = var.messages_visible_alarm_period
      namespace   = "AWS/SQS"
      dimensions = {
        QueueName = each.key
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "NumberOfMessagesReceived"
      stat        = "Sum"
      period      = var.messages_visible_alarm_period
      namespace   = "AWS/SQS"
      dimensions = {
        QueueName = each.key
      }
    }
  }

  metric_query {
    id          = "e1"
    expression  = "IF(m1 > 0 AND m2 == 0, 1)"
    label       = "MessagesInQueueNoMessagesRecieved"
    return_data = true
  }
}
