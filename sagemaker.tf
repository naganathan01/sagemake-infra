
# terraform/sagemaker.tf - SageMaker Pipeline Resources
resource "aws_sagemaker_pipeline" "diabetes_pipeline" {
  pipeline_name         = "${local.name_prefix}-pipeline"
  pipeline_display_name = "${local.name_prefix} Pipeline"
  role_arn             = aws_iam_role.sagemaker_execution_role.arn
  
  pipeline_definition = jsonencode({
    Version = "2020-12-01"
    Metadata = {
      
    }
    Parameters = [
      {
        Name = "InputData"
        Type = "String"
        DefaultValue = "s3://${aws_s3_bucket.mlops_bucket.bucket}/diabetes-prediction/data/patient_data.csv"
      },
      {
        Name = "ModelApprovalStatus"
        Type = "String"
        DefaultValue = "Approved"
      },
      {
        Name = "TrainingInstanceType"
        Type = "String"
        DefaultValue = var.training_instance_type
      }
    ]
    Steps = [
      {
        Name = "DataProcessing"
        Type = "Processing"
        Arguments = {
          ProcessingResources = {
            ClusterConfig = {
              InstanceType   = var.training_instance_type
              InstanceCount  = 1
              VolumeSizeInGB = 30
            }
          }
          AppSpecification = {
            ImageUri = "246618743249.dkr.ecr.${var.aws_region}.amazonaws.com/sagemaker-scikit-learn:0.23-1-cpu-py3"
          }
          RoleArn = aws_iam_role.sagemaker_execution_role.arn
          ProcessingInputs = [
            {
              InputName = "input-1"
              AppManaged = false
              S3Input = {
                S3Uri = "{'Get': 'Parameters.InputData'}"
                LocalPath = "/opt/ml/processing/input"
                S3DataType = "S3Prefix"
                S3InputMode = "File"
                S3DataDistributionType = "FullyReplicated"
                S3CompressionType = "None"
              }
            },
            {
              InputName = "code"
              AppManaged = false
              S3Input = {
                S3Uri = "s3://${aws_s3_bucket.mlops_bucket.bucket}/diabetes-prediction/code/preprocessing.py"
                LocalPath = "/opt/ml/processing/input/code"
                S3DataType = "S3Prefix"
                S3InputMode = "File"
                S3DataDistributionType = "FullyReplicated"
                S3CompressionType = "None"
              }
            }
          ]
          ProcessingOutputs = [
            {
              OutputName = "train"
              AppManaged = false
              S3Output = {
                S3Uri = "s3://${aws_s3_bucket.mlops_bucket.bucket}/diabetes-prediction/processed/train"
                LocalPath = "/opt/ml/processing/output/train"
                S3UploadMode = "EndOfJob"
              }
            },
            {
              OutputName = "test"
              AppManaged = false
              S3Output = {
                S3Uri = "s3://${aws_s3_bucket.mlops_bucket.bucket}/diabetes-prediction/processed/test"
                LocalPath = "/opt/ml/processing/output/test"
                S3UploadMode = "EndOfJob"
              }
            }
          ]
        }
      },
      {
        Name = "ModelTraining"
        Type = "Training"
        Arguments = {
          AlgorithmSpecification = {
            TrainingImage = "246618743249.dkr.ecr.${var.aws_region}.amazonaws.com/sagemaker-scikit-learn:0.23-1-cpu-py3"
            TrainingInputMode = "File"
          }
          RoleArn = aws_iam_role.sagemaker_execution_role.arn
                    InputDataConfig = [
            {
              ChannelName = "train"
              DataSource = {
                S3DataSource = {
                  S3DataType = "S3Prefix"
                  S3Uri = "{'Get': 'Steps.DataProcessing.ProcessingOutputConfig.Outputs.train.S3Output.S3Uri'}"
                  S3DataDistributionType = "FullyReplicated"
                }
              }
              ContentType = "text/csv"
              InputMode = "File"
            }
          ]
          OutputDataConfig = {
            S3OutputPath = "s3://${aws_s3_bucket.mlops_bucket.bucket}/diabetes-prediction/model-artifacts"
          }
          ResourceConfig = {
            InstanceType = "{'Get': 'Parameters.TrainingInstanceType'}"
            InstanceCount = 1
            VolumeSizeInGB = 30
          }
          StoppingCondition = {
            MaxRuntimeInSeconds = 3600
          }
          HyperParameters = {
            "n-estimators" = "100"
            "max-depth" = "10"
          }
        }
      }
    ]
  })

  tags = var.common_tags
}