resource "aws_sns_topic" "msk_alerts" {
  count = var.msk.create && var.msk_alerting.enabled ? 1 : 0
  name  = "${local.pxa_prefix}-msk-alerts"
}

# MSK - Under Replicated Partitions
resource "aws_cloudwatch_metric_alarm" "msk_under_replicated_partitions" {
  count               = var.msk.create && var.msk_alerting.enabled ? 1 : 0
  alarm_name          = "${local.pxa_prefix}-msk-under-replicated-partitions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnderReplicatedPartitions"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main[0].cluster_name
  }

  alarm_description = "MSK has under replicated partitions"

  alarm_actions = [aws_sns_topic.msk_alerts.arn]
  ok_actions    = [aws_sns_topic.msk_alerts.arn]
}

# MSK - Offline Partitions
resource "aws_cloudwatch_metric_alarm" "msk_offline_partitions" {
  count               = var.msk.create && var.msk_alerting.enabled ? 1 : 0
  alarm_name          = "${local.pxa_prefix}-msk-offline-partitions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "OfflinePartitionsCount"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Maximum"
  threshold           = 0

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main[0].cluster_name
  }

  alarm_description = "MSK has offline partitions"

  alarm_actions = [aws_sns_topic.msk_alerts.arn]
  ok_actions    = [aws_sns_topic.msk_alerts.arn]
}

# MSK - Active Controller
resource "aws_cloudwatch_metric_alarm" "msk_active_controller" {
  count               = var.msk.create && var.msk_alerting.enabled ? 1 : 0
  alarm_name          = "${local.pxa_prefix}-msk-active-controller"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ActiveControllerCount"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Maximum"
  threshold           = 1

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main[0].cluster_name
  }

  alarm_description = "MSK active controller count is abnormal"

  alarm_actions = [aws_sns_topic.msk_alerts.arn]
  ok_actions    = [aws_sns_topic.msk_alerts.arn]
}

# MSK - High CPU
resource "aws_cloudwatch_metric_alarm" "msk_cpu_high" {
  count               = var.msk.create && var.msk_alerting.enabled ? 1 : 0
  alarm_name          = "${local.pxa_prefix}-msk-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CpuUser"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main[0].cluster_name
  }

  alarm_description = "MSK CPU utilization above 80%"

  alarm_actions = [aws_sns_topic.msk_alerts.arn]
  ok_actions    = [aws_sns_topic.msk_alerts.arn]
}

# MSK - High Memory
resource "aws_cloudwatch_metric_alarm" "msk_memory_high" {
  count               = var.msk.create && var.msk_alerting.enabled ? 1 : 0
  alarm_name          = "${local.pxa_prefix}-msk-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUsed"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main[0].cluster_name
  }

  alarm_description = "MSK memory utilization above 80%"

  alarm_actions = [aws_sns_topic.msk_alerts.arn]
  ok_actions    = [aws_sns_topic.msk_alerts.arn]
}

# MSK - Low Burst Balance
resource "aws_cloudwatch_metric_alarm" "msk_burst_balance_low" {
  count               = var.msk.create && var.msk_alerting.enabled ? 1 : 0
  alarm_name          = "${local.pxa_prefix}-msk-burst-balance-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "BurstBalance"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main[0].cluster_name
  }

  alarm_description = "MSK EBS burst balance below 20%"

  alarm_actions = [aws_sns_topic.msk_alerts.arn]
  ok_actions    = [aws_sns_topic.msk_alerts.arn]
}

# MSK - Broker Storage Utilization
resource "aws_cloudwatch_metric_alarm" "msk_disk_utilization" {
  count               = var.msk.create && var.msk_alerting.enabled ? 1 : 0
  alarm_name          = "${local.pxa_prefix}-msk-disk-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "KafkaDataLogsDiskUsed"
  namespace           = "AWS/Kafka"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    "Cluster Name" = aws_msk_cluster.main[0].cluster_name
  }

  alarm_description = "MSK broker storage utilization above 80%"

  alarm_actions = [aws_sns_topic.msk_alerts.arn]
  ok_actions    = [aws_sns_topic.msk_alerts.arn]
}

# AWS Chatbot -> Slack
resource "aws_chatbot_slack_channel_configuration" "msk_alerts" {
  count              = var.msk.create && var.msk_alerting.enabled ? 1 : 0
  configuration_name = "${local.pxa_prefix}-msk-alerts"

  slack_team_id    = var.msk.alerting.slack_team_id
  slack_channel_id = var.msk.alerting.slack_channel_id

  iam_role_arn = aws_iam_role.chatbot.arn

  sns_topic_arns = [
    aws_sns_topic.msk_alerts.arn
  ]
}
