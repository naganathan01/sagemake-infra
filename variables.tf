
# terraform/variables.tf - Input Variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "diabetes-prediction-mlops"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "notification_email" {
  description = "Email for notifications"
  type        = string
  default     = ""
}

variable "enable_vpc" {
  description = "Whether to create VPC for secure deployment"
  type        = bool
  default     = false
}

variable "enable_api_gateway" {
  description = "Whether to create API Gateway"
  type        = bool
  default     = true
}

variable "endpoint_instance_type" {
  description = "SageMaker endpoint instance type"
  type        = string
  default     = "ml.t2.medium"
}

variable "training_instance_type" {
  description = "SageMaker training instance type"
  type        = string
  default     = "ml.m5.large"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "diabetes-prediction-mlops"
    Environment = "prod"
    ManagedBy   = "terraform"
    Purpose     = "healthcare-ml"
  }
}
