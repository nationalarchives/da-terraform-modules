output "sqs_arn" {
  value = local.sqs_queue.arn
}

output "dlq_sqs_arn" {
  value = local.sqs_dlq.arn
}

output "sqs_queue_url" {
  value = local.sqs_queue.url
}

output "dlq_sqs_url" {
  value = local.sqs_dlq.url
}

output "dlq_cloudwatch_message_visible_alarm_arn" {
  value = module.dlq_metric_messages_visible_alarm.cloudwatch_alarm_arn
}

output "queue_cloudwatch_message_visible_alarm_arn" {
  value = module.queue_cloudwatch_alarm.cloudwatch_alarm_arn
}
