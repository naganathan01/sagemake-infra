# terraform/data_upload.tf - Data Upload Resources
resource "aws_s3_object" "sample_data" {
  bucket = aws_s3_bucket.mlops_bucket.bucket
  key    = "diabetes-prediction/data/patient_data.csv"
  source = "${path.module}/../data/patient_data.csv"
  etag   = filemd5("${path.module}/../data/patient_data.csv")

  tags = var.common_tags

  depends_on = [aws_s3_bucket.mlops_bucket]
}

resource "aws_s3_object" "preprocessing_script" {
  bucket = aws_s3_bucket.mlops_bucket.bucket
  key    = "diabetes-prediction/code/preprocessing.py"
  source = "${path.module}/../preprocessing.py"
  etag   = filemd5("${path.module}/../preprocessing.py")

  tags = var.common_tags
}

resource "aws_s3_object" "training_script" {
  bucket = aws_s3_bucket.mlops_bucket.bucket
  key    = "diabetes-prediction/code/train.py"
  source = "${path.module}/../train.py"
  etag   = filemd5("${path.module}/../train.py")

  tags = var.common_tags
}

resource "aws_s3_object" "inference_script" {
  bucket = aws_s3_bucket.mlops_bucket.bucket
  key    = "diabetes-prediction/code/inference.py"
  source = "${path.module}/../inference.py"
  etag   = filemd5("${path.module}/../inference.py")

  tags = var.common_tags
}
