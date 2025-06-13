
# terraform/s3.tf - S3 Resources
resource "aws_s3_bucket" "mlops_bucket" {
  bucket = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
  
  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-bucket"
  })
}

resource "aws_s3_bucket_versioning" "mlops_bucket_versioning" {
  bucket = aws_s3_bucket.mlops_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_encryption" "mlops_bucket_encryption" {
  bucket = aws_s3_bucket.mlops_bucket.id

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "mlops_bucket_lifecycle" {
  bucket = aws_s3_bucket.mlops_bucket.id

  rule {
    id     = "model_artifacts_lifecycle"
    status = "Enabled"

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    filter {
      prefix = "model-artifacts/"
    }
  }

  rule {
    id     = "logs_lifecycle"
    status = "Enabled"

    expiration {
      days = 30
    }

    filter {
      prefix = "logs/"
    }
  }
}