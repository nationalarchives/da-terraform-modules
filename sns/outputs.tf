output "sns" {
  value = aws_sns_topic.sns_topic
}
output "sns_arn" {
  value = aws_sns_topic.sns_topic.arn
}

