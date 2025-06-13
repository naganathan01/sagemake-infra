
# terraform/autoscaling.tf - Auto Scaling Configuration
resource "aws_appautoscaling_target" "sagemaker_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "endpoint/${local.name_prefix}-endpoint/variant/AllTraffic"
  scalable_dimension = "sagemaker:variant:DesiredInstanceCount"
  service_namespace  = "sagemaker"

  depends_on = [
    # This will be created after the SageMaker endpoint is deployed
  ]

  tags = var.common_tags
}

resource "aws_appautoscaling_policy" "sagemaker_scaling_policy" {
  name               = "${local.name_prefix}-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.sagemaker_target.resource_id
  scalable_dimension = aws_appautoscaling_target.sagemaker_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.sagemaker_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 70.0

    predefined_metric_specification {
      predefined_metric_type = "SageMakerVariantInvocationsPerInstance"
    }

    scale_out_cooldown = 300
    scale_in_cooldown  = 300
  }
}