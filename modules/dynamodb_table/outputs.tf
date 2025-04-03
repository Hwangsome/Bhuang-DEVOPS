output "table_id" {
  description = "The name of the table"
  value       = aws_dynamodb_table.this.id
}

output "table_arn" {
  description = "The ARN of the table"
  value       = aws_dynamodb_table.this.arn
}

output "stream_arn" {
  description = "The ARN of the Table Stream. Only available when stream_enabled = true"
  value       = try(aws_dynamodb_table.this.stream_arn, "")
}

output "stream_label" {
  description = "A timestamp, in ISO 8601 format of the Table Stream. Only available when stream_enabled = true"
  value       = try(aws_dynamodb_table.this.stream_label, "")
}
