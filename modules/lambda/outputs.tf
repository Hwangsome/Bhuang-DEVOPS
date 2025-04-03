output "lambda_function_arn" {
  description = "The ARN of the Lambda Function"
  value       = try(aws_lambda_function.this[0].arn, "")
}

output "lambda_function_name" {
  description = "The name of the Lambda Function"
  value       = try(aws_lambda_function.this[0].function_name, "")
}

output "lambda_function_qualified_arn" {
  description = "The ARN identifying your Lambda Function Version"
  value       = try(aws_lambda_function.this[0].qualified_arn, "")
}

output "lambda_function_version" {
  description = "The version of the Lambda Function"
  value       = try(aws_lambda_function.this[0].version, "")
}

output "lambda_function_last_modified" {
  description = "The date the Lambda Function was last modified"
  value       = try(aws_lambda_function.this[0].last_modified, "")
}

output "lambda_function_source_code_hash" {
  description = "Base64-encoded representation of raw SHA-256 sum of the zip file"
  value       = try(aws_lambda_function.this[0].source_code_hash, "")
}

output "lambda_function_source_code_size" {
  description = "The size in bytes of the function .zip file"
  value       = try(aws_lambda_function.this[0].source_code_size, "")
}

output "lambda_function_invoke_arn" {
  description = "The ARN to be used for invoking Lambda Function from API Gateway"
  value       = try(aws_lambda_function.this[0].invoke_arn, "")
}

output "lambda_role_arn" {
  description = "The ARN of the IAM role created for the Lambda Function"
  value       = try(aws_iam_role.lambda[0].arn, "")
}

output "lambda_role_name" {
  description = "The name of the IAM role created for the Lambda Function"
  value       = try(aws_iam_role.lambda[0].name, "")
}

output "lambda_layer_arn" {
  description = "The ARN of the Lambda Layer"
  value       = try(aws_lambda_layer_version.this[0].arn, "")
}

output "lambda_layer_layer_arn" {
  description = "The ARN identifying the created Layer"
  value       = try(aws_lambda_layer_version.this[0].layer_arn, "")
}

output "lambda_layer_created_date" {
  description = "The date the Layer was created"
  value       = try(aws_lambda_layer_version.this[0].created_date, "")
}

output "lambda_layer_source_code_size" {
  description = "The size in bytes of the Layer .zip file"
  value       = try(aws_lambda_layer_version.this[0].source_code_size, "")
}

output "lambda_layer_version" {
  description = "The version of the created Layer"
  value       = try(aws_lambda_layer_version.this[0].version, "")
}

output "lambda_alias_arn" {
  description = "The ARN of the Lambda Function Alias"
  value       = try(aws_lambda_alias.this[0].arn, "")
}

output "lambda_alias_invoke_arn" {
  description = "The ARN to be used for invoking Lambda Function from API Gateway"
  value       = try(aws_lambda_alias.this[0].invoke_arn, "")
}

output "lambda_function_url" {
  description = "The URL of the Lambda Function URL"
  value       = try(aws_lambda_function_url.this[0].function_url, "")
}

output "lambda_function_url_id" {
  description = "The Lambda Function URL identifier"
  value       = try(aws_lambda_function_url.this[0].url_id, "")
}
