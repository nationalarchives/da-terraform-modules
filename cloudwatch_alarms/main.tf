resource "aws_cloudwatch_metric_alarm" "cloudwatch_metric_alarm" {
  alarm_name          = var.name
  comparison_operator = var.comparison_operator
  evaluation_periods  = var.evaluation_period
  datapoints_to_alarm = var.datapoints_to_alarm
  treat_missing_data  = var.treat_missing_data
  threshold           = var.threshold
  dimensions          = var.dimensions
  metric_name         = var.metric_name
  namespace           = var.namespace
  actions_enabled     = var.notification_topic == null ? false : true
  alarm_actions       = var.notification_topic == null ? [] : [var.notification_topic]
  ok_actions          = var.notification_topic == null ? [] : [var.notification_topic]
  statistic           = var.extended_statistic == null ? var.statistic : null
  extended_statistic  = var.extended_statistic
  period              = var.period
}
