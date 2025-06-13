# terraform/versions.tf - Version constraints
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
  
  # Optional: Configure remote state
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "diabetes-mlops/terraform.tfstate"
  #   region = "us-east-1"
  # }
}
