

# terraform/cloudwatch.tf - CloudWatch Resources
resource "aws_cloudwatch_dashboard" "mlops_dashboard" {
  dashboard_name = "${local.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/SageMaker/Endpoints", "Invocations", "EndpointName", "${local.name_prefix}-endpoint"],
            [".", "InvocationsPerInstance", ".", "."],
            [".", "ModelLatency", ".", "."],
            [".", "OverheadLatency", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Endpoint Metrics"
          period  = 300
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          query  = "SOURCE '/aws/sagemaker/Endpoints/${local.name_prefix}-endpoint'\n| fields @timestamp, @message\n| filter @message like /ERROR/\n| sort @timestamp desc\n| limit 20"
          region = var.aws_region
          title  = "Endpoint Errors"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "endpoint_latency" {
  alarm_name          = "${local.name_prefix}-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ModelLatency"
  namespace           = "AWS/SageMaker/Endpoints"
  period              = "300"
  statistic           = "Average"
  threshold           = "1000"
  alarm_description   = "This metric monitors endpoint latency"
  alarm_actions       = var.notification_email != "" ? [aws_sns_topic.mlops_alerts[0].arn] : []

  dimensions = {
    EndpointName = "${local.name_prefix}-endpoint"
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "endpoint_invocations" {
  alarm_name          = "${local.name_prefix}-low-invocations"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Invocations"
  namespace           = "AWS/SageMaker/Endpoints"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "This metric monitors endpoint usage"
  alarm_actions       = var.notification_email != "" ? [aws_sns_topic.mlops_alerts[0].arn] : []

  dimensions = {
    EndpointName = "${local.name_prefix}-endpoint"
  }

  tags = var.common_tags
}

