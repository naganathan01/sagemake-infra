
# terraform/lambda.tf - Lambda Resources
data "archive_file" "lambda_retraining_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_retraining.zip"
  
  source {
    content = templatefile("${path.module}/../lambda_retraining.py", {
      pipeline_name = "${local.name_prefix}-pipeline"
      endpoint_name = "${local.name_prefix}-endpoint"
      sns_topic_arn = var.notification_email != "" ? aws_sns_topic.mlops_alerts[0].arn : ""
    })
    filename = "lambda_function.py"
  }
}

resource "aws_lambda_function" "retraining_trigger" {
  filename         = data.archive_file.lambda_retraining_zip.output_path
  function_name    = "${local.name_prefix}-retraining"
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_retraining_zip.output_base64sha256
  runtime         = "python3.9"
  timeout         = 300

  environment {
    variables = {
      PIPELINE_NAME = "${local.name_prefix}-pipeline"
      ENDPOINT_NAME = "${local.name_prefix}-endpoint"
      SNS_TOPIC_ARN = var.notification_email != "" ? aws_sns_topic.mlops_alerts[0].arn : ""
    }
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_event_rule" "retraining_schedule" {
  name                = "${local.name_prefix}-retraining-schedule"
  description         = "Trigger retraining check weekly"
  schedule_expression = "rate(7 days)"
  
  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.retraining_schedule.name
  target_id = "RetrainingLambdaTarget"
  arn       = aws_lambda_function.retraining_trigger.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.retraining_trigger.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.retraining_schedule.arn
}
