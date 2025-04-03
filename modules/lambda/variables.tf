variable "create" {
  description = "Controls whether resources should be created"
  type        = bool
  default     = true
}

variable "create_function" {
  description = "Controls whether Lambda Function resource should be created"
  type        = bool
  default     = true
}

variable "create_layer" {
  description = "Controls whether Lambda Layer resource should be created"
  type        = bool
  default     = false
}

variable "create_role" {
  description = "Controls whether IAM role for Lambda Function should be created"
  type        = bool
  default     = true
}

variable "create_lambda_function_url" {
  description = "Controls whether the Lambda Function URL resource should be created"
  type        = bool
  default     = false
}

variable "create_alias" {
  description = "Controls whether Lambda Alias resource should be created"
  type        = bool
  default     = false
}

###########
# Function
###########

variable "lambda_at_edge" {
  description = "Set this to true if using Lambda@Edge, to enable publishing, limit the timeout, and allow edgelambda.amazonaws.com to invoke the function"
  type        = bool
  default     = false
}

variable "function_name" {
  description = "A unique name for your Lambda Function"
  type        = string
  default     = ""
}

variable "handler" {
  description = "Lambda Function entrypoint in your code"
  type        = string
  default     = ""
}

variable "runtime" {
  description = "Lambda Function runtime"
  type        = string
  default     = ""
}

variable "lambda_role" {
  description = "IAM role ARN attached to the Lambda Function. Required if create_role is false."
  type        = string
  default     = ""
}

variable "description" {
  description = "Description of your Lambda Function (or Layer)"
  type        = string
  default     = ""
}

variable "layers" {
  description = "List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function"
  type        = list(string)
  default     = null
}

variable "package_type" {
  description = "Lambda deployment package type - 'Zip' or 'Image'"
  type        = string
  default     = "Zip"
}

variable "architectures" {
  description = "Instruction set architecture for your Lambda Function. Valid values are ['x86_64'] and ['arm64']."
  type        = list(string)
  default     = null
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime. Valid value between 128 MB to 10,240 MB (10 GB), in 64 MB increments."
  type        = number
  default     = 128
}

variable "timeout" {
  description = "The amount of time your Lambda Function has to run in seconds."
  type        = number
  default     = 3
}

variable "reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for this lambda function or -1 if unreserved."
  type        = number
  default     = null
}

variable "publish" {
  description = "Whether to publish creation/change as new Lambda Function Version."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "The ARN of KMS key to use by your Lambda Function"
  type        = string
  default     = null
}

variable "code_signing_config_arn" {
  description = "Amazon Resource Name (ARN) for a Code Signing Configuration"
  type        = string
  default     = null
}

###############
# Code Package
###############

variable "filename" {
  description = "The path to the function's deployment package within the local filesystem. If defined, The s3_* variables will be ignored."
  type        = string
  default     = null
}

variable "source_code_hash" {
  description = "Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the package file specified with either filename or s3_key."
  type        = string
  default     = null
}

variable "local_existing_package" {
  description = "The absolute path to an existing zip-file to use"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket to store artifacts"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of artifacts"
  type        = string
  default     = null
}

variable "s3_existing_package" {
  description = "Existing S3 object in format: bucket_name:key:version_id"
  type = object({
    bucket     = string
    key        = string
    version_id = optional(string)
  })
  default = null
}

variable "image_uri" {
  description = "The ECR image URI containing the function's deployment package."
  type        = string
  default     = null
}

#############
# Environment
#############

variable "environment_variables" {
  description = "A map of environment variables to pass to the Lambda function"
  type        = map(string)
  default     = {}
}

#######
# VPC
#######

variable "vpc_subnet_ids" {
  description = "List of subnet ids when Lambda Function should run in the VPC. Usually private or intra subnets."
  type        = list(string)
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of security group ids when Lambda Function should run in the VPC."
  type        = list(string)
  default     = null
}

#########
# Tracing
#########

variable "tracing_mode" {
  description = "Tracing mode of the Lambda Function. Valid value can be either PassThrough or Active."
  type        = string
  default     = null
}

variable "attach_tracing_policy" {
  description = "Controls whether X-Ray tracing policy should be added to IAM role for Lambda Function"
  type        = bool
  default     = false
}

##########
# Dead Letter Queue
##########

variable "dead_letter_target_arn" {
  description = "The ARN of an SNS topic or SQS queue to notify when an invocation fails."
  type        = string
  default     = null
}

variable "attach_dead_letter_policy" {
  description = "Controls whether SNS/SQS dead letter notification policy should be added to IAM role for Lambda Function"
  type        = bool
  default     = false
}

#############
# CloudWatch Logs
#############

variable "attach_cloudwatch_logs_policy" {
  description = "Controls whether CloudWatch Logs policy should be added to IAM role for Lambda Function"
  type        = bool
  default     = true
}

###########
# IAM role
###########

variable "role_name" {
  description = "Name of IAM role to use for Lambda Function"
  type        = string
  default     = null
}

variable "role_description" {
  description = "Description of IAM role to use for Lambda Function"
  type        = string
  default     = null
}

variable "role_path" {
  description = "Path of IAM role to use for Lambda Function"
  type        = string
  default     = null
}

variable "role_force_detach_policies" {
  description = "Specifies to force detaching any policies the IAM role has before destroying it"
  type        = bool
  default     = true
}

variable "role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the IAM role used by Lambda Function"
  type        = string
  default     = null
}

variable "attach_policy_arns" {
  description = "A list of IAM Policy ARNs to attach to the generated IAM role"
  type        = list(string)
  default     = []
}

variable "attach_policy_json" {
  description = "Map of JSON IAM policy documents to attach to the generated IAM role"
  type        = map(string)
  default     = {}
}

variable "attach_network_policy" {
  description = "Controls whether VPC/network policy should be added to IAM role for Lambda Function"
  type        = bool
  default     = false
}

#############
# Lambda Layer
#############

variable "layer_name" {
  description = "Name of Lambda Layer to create"
  type        = string
  default     = ""
}

variable "compatible_runtimes" {
  description = "A list of Runtimes this layer is compatible with"
  type        = list(string)
  default     = []
}

variable "layer_skip_destroy" {
  description = "Whether to retain the old version of a previously deployed Lambda Layer"
  type        = bool
  default     = false
}

###############
# Lambda Alias
###############

variable "alias_name" {
  description = "Name for the alias"
  type        = string
  default     = ""
}

variable "alias_description" {
  description = "Description of the alias"
  type        = string
  default     = ""
}

variable "alias_function_version" {
  description = "Function version to use for the alias"
  type        = string
  default     = null
}

variable "alias_routing_additional_version" {
  description = "Additional version to route traffic to"
  type        = string
  default     = null
}

variable "alias_routing_additional_version_weight" {
  description = "Weight of additional version traffic (percentage)"
  type        = number
  default     = null
}

#################
# Lambda Function URL
#################

variable "authorization_type" {
  description = "The type of authentication that the function URL uses. The only valid value is 'AWS_IAM' or 'NONE'"
  type        = string
  default     = "NONE"
}

variable "cors_allow_credentials" {
  description = "Whether to allow cookies or other credentials in requests to the function URL"
  type        = bool
  default     = false
}

variable "cors_allow_origins" {
  description = "The origins that are allowed to make requests to the function URL"
  type        = list(string)
  default     = []
}

variable "cors_allow_methods" {
  description = "The HTTP methods that are allowed when calling the function URL"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allow_headers" {
  description = "The HTTP headers that are allowed when calling the function URL"
  type        = list(string)
  default     = ["date", "keep-alive"]
}

variable "cors_expose_headers" {
  description = "The HTTP headers in your function response that you want to expose to CORS clients"
  type        = list(string)
  default     = ["keep-alive", "date"]
}

variable "cors_max_age" {
  description = "The maximum amount of time, in seconds, that browsers can cache the results of a preflight request"
  type        = number
  default     = 0
}

############
# File system
############

variable "file_system_arn" {
  description = "The Amazon Resource Name (ARN) of the Amazon EFS Access Point that provides access to the file system"
  type        = string
  default     = null
}

variable "file_system_local_mount_path" {
  description = "The path where the function can access the file system, starting with /mnt/"
  type        = string
  default     = null
}

###########
# Tags
###########

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}
