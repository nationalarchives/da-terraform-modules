output "dlq_sqs_arn" {
  value = local.sqs_dlq.arn
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

output "recurring_notification_alarm_arns" {
  value = [for alarm in aws_cloudwatch_metric_alarm.new_messages_added_to_dlq_alert : alarm.arn]
}
