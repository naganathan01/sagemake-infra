# terraform/model_monitoring.tf - Model Monitoring Resources
resource "aws_sagemaker_data_quality_job_definition" "diabetes_data_quality" {
  name     = "${local.name_prefix}-data-quality-job"
  role_arn = aws_iam_role.sagemaker_execution_role.arn

  data_quality_app_specification {
    image_uri = "159807026194.dkr.ecr.${var.aws_region}.amazonaws.com/sagemaker-model-monitor-analyzer"
  }

  data_quality_baseline_config {
    baselining_job_name = "${local.name_prefix}-baseline-job"
    
    constraints_resource {
      s3_uri = "s3://${aws_s3_bucket.mlops_bucket.bucket}/diabetes-prediction/baseline/constraints.json"
    }
    
    statistics_resource {
      s3_uri = "s3://${aws_s3_bucket.mlops_bucket.bucket}/diabetes-prediction/baseline/statistics.json"
    }
  }

  data_quality_job_input {
    endpoint_input {
      endpoint_name           = "${local.name_prefix}-endpoint"
      local_path              = "/opt/ml/processing/input/endpoint"
      s3_data_distribution_type = "FullyReplicated"
      s3_input_mode           = "File"
    }
  }

  data_quality_job_output_config {
    monitoring_outputs {
      s3_output {
        s3_uri     = "s3://${aws_s3_bucket.mlops_bucket.bucket}/diabetes-prediction/monitoring-reports"
        local_path = "/opt/ml/processing/output"
        s3_upload_mode = "EndOfJob"
      }
    }
  }

  job_resources {
    cluster_config {
      instance_count   = 1
      instance_type    = "ml.m5.large"
      volume_size_in_gb = 20
    }
  }

  stopping_condition {
    max_runtime_in_seconds = 3600
  }

  tags = var.common_tags
}
