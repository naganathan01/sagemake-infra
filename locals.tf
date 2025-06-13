
# terraform/locals.tf - Local Values
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  sagemaker_policies = [
    "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  ]
  
  lambda_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  ]
}
