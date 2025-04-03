variable "name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

variable "handler" {
  description = "The function entrypoint in your code"
  type        = string
}

variable "runtime" {
  description = "The runtime environment for the Lambda function"
  type        = string
}

variable "role_arn" {
  description = "The ARN of the IAM role that Lambda assumes when it executes your function"
  type        = string
}

variable "filename" {
  description = "The path to the function's deployment package within the local filesystem"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "The S3 bucket location containing the function's deployment package"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "The S3 key of an object containing the function's deployment package"
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Used to trigger updates when file contents change"
  type        = string
  default     = null
}

variable "timeout" {
  description = "The amount of time your Lambda function has to run in seconds"
  type        = number
  default     = 3
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda function can use at runtime"
  type        = number
  default     = 128
}

variable "publish" {
  description = "Whether to publish creation/change as new Lambda function version"
  type        = bool
  default     = false
}

variable "environment_variables" {
  description = "A map of environment variables to pass to the Lambda function"
  type        = map(string)
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs associated with the Lambda function"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs associated with the Lambda function"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the Lambda function"
  type        = map(string)
  default     = {}
}
