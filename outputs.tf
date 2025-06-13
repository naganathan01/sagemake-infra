
# terraform/outputs.tf - Output Values
output "s3_bucket_name" {
  description = "Name of the S3 bucket for MLOps artifacts"
  value       = aws_s3_bucket.mlops_bucket.bucket
}

output "sagemaker_execution_role_arn" {
  description = "ARN of the SageMaker execution role"
  value       = aws_iam_role.sagemaker_execution_role.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function for automated retraining"
  value       = aws_lambda_function.retraining_trigger.function_name
}

output "cloudwatch_dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.mlops_dashboard.dashboard_name}"
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for notifications"
  value       = var.notification_email != "" ? aws_sns_topic.mlops_alerts[0].arn : null
}

output "api_gateway_url" {
  description = "URL of the API Gateway endpoint"
  value       = var.enable_api_gateway ? "https://${aws_api_gateway_rest_api.diabetes_api[0].id}.execute-api.${var.aws_region}.amazonaws.com/prod" : null
}

output "vpc_id" {
  description = "ID of the VPC (if created)"
  value       = var.enable_vpc ? aws_vpc.mlops_vpc[0].id : null
}

output "private_subnet_ids" {
  description = "IDs of the private subnets (if VPC created)"
  value       = var.enable_vpc ? aws_subnet.private_subnet[*].id : null
}

output "security_group_id" {
  description = "ID of the SageMaker security group (if VPC created)"
  value       = var.enable_vpc ? aws_security_group.sagemaker_sg[0].id : null
}

output "setup_summary" {
  description = "Summary of created resources"
  value = {
    project_name    = var.project_name
    environment     = var.environment
    region         = var.aws_region
    s3_bucket      = aws_s3_bucket.mlops_bucket.bucket
    role_arn       = aws_iam_role.sagemaker_execution_role.arn
    vpc_enabled    = var.enable_vpc
    api_enabled    = var.enable_api_gateway
    notifications  = var.notification_email != ""
  }
}