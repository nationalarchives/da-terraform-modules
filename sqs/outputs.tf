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

output "dlq_cloudwatch_alarm_arn" {
  value = var.dlq_notification_topic == "" ? "" : module.dlq_cloudwatch_alarm.*.cloudwatch_alarm_arn[0]
}
