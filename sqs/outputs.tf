output "sqs_arn" {
  value = aws_sqs_queue.sqs_queue.arn
}

output "dlq_sqs_arn" {
  value = aws_sqs_queue.dlq.arn
}
