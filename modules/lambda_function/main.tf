resource "aws_lambda_function" "this" {
  function_name    = var.name
  description      = var.description
  handler          = var.handler
  runtime          = var.runtime
  role             = var.role_arn
  filename         = var.filename
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key
  source_code_hash = var.source_code_hash
  timeout          = var.timeout
  memory_size      = var.memory_size
  publish          = var.publish
  
  dynamic "environment" {
    for_each = var.environment_variables != null ? [1] : []
    content {
      variables = var.environment_variables
    }
  }
  
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
  
  tags = var.tags
}
