resource "aws_sns_topic" "sns_topic" {
  name   = var.topic_name
  policy = var.sns_policy

  tags = merge(
    var.tags,
    tomap(
      { "Name" = var.topic_name }
    )
  )
  kms_master_key_id = var.kms_key_arn
}

resource "aws_sns_topic_subscription" "lambda_subscriptions" {
  for_each             = var.lambda_subscriptions
  endpoint             = each.value
  protocol             = "lambda"
  topic_arn            = aws_sns_topic.sns_topic.arn
  raw_message_delivery = false
}

resource "aws_sns_topic_subscription" "sqs_subscriptions" {
  for_each             = var.sqs_subscriptions
  endpoint             = each.value
  protocol             = "sqs"
  topic_arn            = aws_sns_topic.sns_topic.arn
  raw_message_delivery = true
}
