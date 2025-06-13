# terraform/terraform.tfvars.example - Example configuration file
aws_region            = "us-east-1"
project_name          = "diabetes-prediction-mlops"
environment           = "prod"
notification_email    = "your-email@example.com"
enable_vpc           = false
enable_api_gateway   = true
endpoint_instance_type = "ml.t2.medium"
training_instance_type = "ml.m5.large"

common_tags = {
  Project     = "diabetes-prediction-mlops"
  Environment = "prod"
  ManagedBy   = "terraform"
  Purpose     = "healthcare-ml"
  Owner       = "data-science-team"
}