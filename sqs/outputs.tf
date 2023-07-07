output "sqs_arn" {
  value = var.kms_key_id == null ? aws_sqs_queue.sqs_queue_with_sse[0].arn : aws_sqs_queue.sqs_queue_with_kms[0].arn
}

output "dlq_sqs_arn" {
  value = aws_sqs_queue.dlq.arn
}

output "sqs_queue_url" {
  value = var.kms_key_id == null ? aws_sqs_queue.sqs_queue_with_sse[0].url : aws_sqs_queue.sqs_queue_with_kms[0].url
}

output "dlq_sqs_url" {
  value = aws_sqs_queue.dlq.url
}

output "dlq_cloudwatch_alarm_arn" {
  value = var.dlq_notification_topic == "" ? "" : module.dlq_metadata_and_files_cloudwatch_alarm.*.cloudwatch_alarm_arn[0]
}
