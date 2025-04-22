output "sqs_arn" {
  value = local.sqs_queue.arn
}

output "sqs_queue_url" {
  value = local.sqs_queue.url
}

output "dlq_sqs_arn" {
  value = local.sqs_dlq.arn
}

output "dlq_sqs_url" {
  value = local.sqs_dlq.url
}

output "alarms" {
  value = [module.queue_cloudwatch_alarm.cloudwatch_alarm_arn, module.dlq_metric_messages_visible_alarm.cloudwatch_alarm_arn]
}

output "event_alarms" {
  value = [aws_cloudwatch_metric_alarm.new_messages_added_to_dlq_alert.arn]
}
