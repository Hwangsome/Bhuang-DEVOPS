data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  create = var.create

  # Determine whether to use local file or S3 for deployment package
  package_type     = var.package_type
  filename         = var.local_existing_package != null ? var.local_existing_package : var.filename
  source_code_hash = var.source_code_hash != null ? var.source_code_hash : (var.local_existing_package != null ? filebase64sha256(var.local_existing_package) : null)
  
  # S3 object configuration
  s3_bucket         = var.s3_existing_package != null ? var.s3_existing_package.bucket : var.s3_bucket
  s3_key            = var.s3_existing_package != null ? var.s3_existing_package.key : var.s3_key
  s3_object_version = var.s3_existing_package != null ? var.s3_existing_package.version_id : null

  final_function_name = var.function_name
  final_description   = var.description
  final_create_role   = var.create_role
  final_lambda_role   = var.lambda_role
  final_handler       = var.handler
  final_memory_size   = var.memory_size
  final_package_type  = var.package_type
  final_runtime       = var.runtime
  final_layers        = var.layers
  final_timeout       = var.timeout
  final_publish       = var.publish
  final_environment_variables = var.environment_variables
  final_vpc_subnet_ids = var.vpc_subnet_ids
  final_vpc_security_group_ids = var.vpc_security_group_ids
  final_dead_letter_target_arn = var.dead_letter_target_arn
  final_tracing_mode = var.tracing_mode
}

resource "aws_lambda_function" "this" {
  count = local.create && var.create_function && !var.create_layer ? 1 : 0

  function_name                  = local.final_function_name
  description                    = local.final_description
  role                           = local.final_create_role ? aws_iam_role.lambda[0].arn : local.final_lambda_role
  handler                        = local.final_package_type != "Image" ? local.final_handler : null
  memory_size                    = local.final_memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  runtime                        = local.final_package_type != "Image" ? local.final_runtime : null
  layers                         = local.final_layers
  timeout                        = local.final_timeout
  publish                        = local.final_publish
  kms_key_arn                    = var.kms_key_arn
  image_uri                      = var.image_uri
  package_type                   = var.package_type
  architectures                  = var.architectures
  code_signing_config_arn        = var.code_signing_config_arn

  # Use filename/source_code_hash for deployment package via local file
  filename         = var.package_type == "Zip" && var.local_existing_package != null ? local.filename : null
  source_code_hash = var.package_type == "Zip" && var.local_existing_package != null ? local.source_code_hash : null

  # Use S3 for deployment package
  s3_bucket         = var.package_type == "Zip" && var.s3_existing_package != null ? local.s3_bucket : null
  s3_key            = var.package_type == "Zip" && var.s3_existing_package != null ? local.s3_key : null
  s3_object_version = var.package_type == "Zip" && var.s3_existing_package != null ? local.s3_object_version : null

  # Environment variables
  dynamic "environment" {
    for_each = length(local.final_environment_variables) > 0 ? [true] : []
    
    content {
      variables = local.final_environment_variables
    }
  }

  # VPC configuration
  dynamic "vpc_config" {
    for_each = length(local.final_vpc_subnet_ids) > 0 && length(local.final_vpc_security_group_ids) > 0 ? [true] : []
    
    content {
      subnet_ids         = local.final_vpc_subnet_ids
      security_group_ids = local.final_vpc_security_group_ids
    }
  }

  # Dead Letter Queue
  dynamic "dead_letter_config" {
    for_each = local.final_dead_letter_target_arn != null ? [true] : []
    
    content {
      target_arn = local.final_dead_letter_target_arn
    }
  }

  # Tracing config
  dynamic "tracing_config" {
    for_each = local.final_tracing_mode != null ? [true] : []
    
    content {
      mode = local.final_tracing_mode
    }
  }

  # File system config for EFS
  dynamic "file_system_config" {
    for_each = var.file_system_arn != null && var.file_system_local_mount_path != null ? [true] : []
    
    content {
      arn              = var.file_system_arn
      local_mount_path = var.file_system_local_mount_path
    }
  }

  tags = var.tags
}

# Lambda Layer
resource "aws_lambda_layer_version" "this" {
  count = local.create && var.create_layer ? 1 : 0

  layer_name          = var.layer_name
  description         = var.description
  compatible_runtimes = var.compatible_runtimes

  filename         = local.filename
  source_code_hash = local.source_code_hash

  s3_bucket         = local.s3_bucket
  s3_key            = local.s3_key
  s3_object_version = local.s3_object_version

  skip_destroy = var.layer_skip_destroy
}

# Lambda Alias
resource "aws_lambda_alias" "this" {
  count = local.create && var.create_function && !var.create_layer && var.create_alias ? 1 : 0

  name             = var.alias_name
  description      = var.alias_description
  function_name    = aws_lambda_function.this[0].function_name
  function_version = var.alias_function_version != null ? var.alias_function_version : aws_lambda_function.this[0].version

  # Routing config for Lambda aliases
  dynamic "routing_config" {
    for_each = var.alias_routing_additional_version != null && var.alias_routing_additional_version_weight != null ? [true] : []

    content {
      additional_version_weights = {
        (var.alias_routing_additional_version) = var.alias_routing_additional_version_weight
      }
    }
  }
}

# Lambda Function URL
resource "aws_lambda_function_url" "this" {
  count = local.create && var.create_function && !var.create_layer && var.create_lambda_function_url ? 1 : 0

  function_name      = aws_lambda_function.this[0].function_name
  qualifier          = var.create_alias ? aws_lambda_alias.this[0].name : null
  authorization_type = var.authorization_type

  cors {
    allow_credentials = var.cors_allow_credentials
    allow_origins     = var.cors_allow_origins
    allow_methods     = var.cors_allow_methods
    allow_headers     = var.cors_allow_headers
    expose_headers    = var.cors_expose_headers
    max_age           = var.cors_max_age
  }
}
