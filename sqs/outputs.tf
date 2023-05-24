output "sqs_arn" {
  value = aws_sqs_queue.sqs_queue.arn
}

output "dlq_sqs_arn" {
  value = aws_sqs_queue.dlq.arn
}

output "sqs_queue_url" {
  value = aws_sqs_queue.sqs_queue.url
}

output "dlq_sqs_url" {
  value = aws_sqs_queue.dlq.url
}
