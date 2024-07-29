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
  value = aws_cloudwatch_metric_alarm.dlq_metric_alarm.arn
}

output "dlq_cloudwatch_message_visible_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.dlq_metric_messages_visible_alarm.arn
}

output "dlq_cloudwatch_message_sent_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.dlq_metric_messages_sent_alarm.arn
}
