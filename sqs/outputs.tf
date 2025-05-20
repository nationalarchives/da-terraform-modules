output "sqs_arn" {
  value = local.sqs_queue.arn
}

output "sqs_queue_url" {
  value = local.sqs_queue.url
}

output "dlq_sqs_arn" {
  value = var.create_dlq ? local.sqs_dlq[0].arn : null
}

output "dlq_sqs_url" {
  value = var.create_dlq ? local.sqs_dlq[0].url : null
}

output "alarms" {
  value = flatten([[module.queue_cloudwatch_alarm.cloudwatch_alarm_arn], module.dlq_metric_messages_visible_alarm.*.cloudwatch_alarm_arn])
}

output "event_alarms" {
  value = aws_cloudwatch_metric_alarm.new_messages_added_to_dlq_alert.*.arn
}
