

# terraform/sns.tf - SNS Resources
resource "aws_sns_topic" "mlops_alerts" {
  count = var.notification_email != "" ? 1 : 0
  name  = "${local.name_prefix}-alerts"
  
  tags = var.common_tags
}

resource "aws_sns_topic_subscription" "email_notification" {
  count     = var.notification_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.mlops_alerts[0].arn
  protocol  = "email"
  endpoint  = var.notification_email
}