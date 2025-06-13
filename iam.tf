

# terraform/iam.tf - IAM Resources
resource "aws_iam_role" "sagemaker_execution_role" {
  name               = "${local.name_prefix}-sagemaker-role"
  assume_role_policy = data.aws_iam_policy_document.sagemaker_assume_role.json
  
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "sagemaker_policies" {
  count      = length(local.sagemaker_policies)
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = local.sagemaker_policies[count.index]
}

resource "aws_iam_role_policy" "sagemaker_s3_policy" {
  name = "${local.name_prefix}-sagemaker-s3-policy"
  role = aws_iam_role.sagemaker_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.mlops_bucket.arn,
          "${aws_s3_bucket.mlops_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "${local.name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_policies" {
  count      = length(local.lambda_policies)
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = local.lambda_policies[count.index]
}

resource "aws_iam_role" "api_gateway_role" {
  count              = var.enable_api_gateway ? 1 : 0
  name               = "${local.name_prefix}-api-gateway-role"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_assume_role[0].json
  
  tags = var.common_tags
}

resource "aws_iam_role_policy" "api_gateway_sagemaker_policy" {
  count = var.enable_api_gateway ? 1 : 0
  name  = "${local.name_prefix}-api-gateway-sagemaker-policy"
  role  = aws_iam_role.api_gateway_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sagemaker:InvokeEndpoint"
        ]
        Resource = "*"
      }
    ]
  })
}
