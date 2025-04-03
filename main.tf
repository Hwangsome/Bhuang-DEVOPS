terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.default_tags
  }
}

# 使用 Terraform 内置的 yamldecode 函数读取和解析 YAML 配置文件
locals {
  config_content = fileexists(var.config_file) ? file(var.config_file) : "{}"
  config         = yamldecode(local.config_content)
}

# 创建 S3 存储桶
module "s3_bucket" {
  source   = "./modules/s3_bucket"
  for_each = { for bucket in try(local.config.s3_buckets, []) : bucket.name => bucket }

  name = each.key
  tags = try(each.value.tags, {})

  # 可选参数
  object_ownership       = try(each.value.object_ownership, "BucketOwnerEnforced")
  block_public_acls      = try(each.value.block_public_acls, true)
  block_public_policy    = try(each.value.block_public_policy, true)
  ignore_public_acls     = try(each.value.ignore_public_acls, true)
  restrict_public_buckets = try(each.value.restrict_public_buckets, true)
  policy                 = try(each.value.policy, null)
  enable_versioning      = try(each.value.enable_versioning, false)
  encryption_enabled     = try(each.value.encryption_enabled, true)
  sse_algorithm          = try(each.value.sse_algorithm, "AES256")
}

# 创建 EC2 实例
module "ec2_instance" {
  source   = "./modules/ec2_instance"
  for_each = { for instance in try(local.config.ec2_instances, []) : instance.name => instance }

  name         = each.key
  ami          = each.value.ami
  instance_type = each.value.instance_type
  subnet_id    = try(each.value.subnet_id, null)
  key_name     = try(each.value.key_name, null)
  security_group_ids = try(each.value.security_group_ids, [])
  iam_instance_profile = try(each.value.iam_instance_profile, null)
  user_data    = try(each.value.user_data, null)
  root_block_device = try(each.value.root_block_device, null)
  ebs_block_device = try(each.value.ebs_block_device, [])
  tags         = try(each.value.tags, {})
}

# 创建 DynamoDB 表
module "dynamodb_table" {
  source   = "./modules/dynamodb_table"
  for_each = { for table in try(local.config.dynamodb_tables, []) : table.name => table }

  name           = each.key
  billing_mode   = try(each.value.billing_mode, "PAY_PER_REQUEST")
  read_capacity  = try(each.value.read_capacity, null)
  write_capacity = try(each.value.write_capacity, null)
  hash_key       = each.value.hash_key
  range_key      = try(each.value.range_key, null)
  attributes     = each.value.attributes

  global_secondary_indexes = try(each.value.global_secondary_indexes, [])
  local_secondary_indexes  = try(each.value.local_secondary_indexes, [])

  ttl_enabled      = try(each.value.ttl_enabled, false)
  ttl_attribute_name = try(each.value.ttl_attribute_name, "TimeToExist")
  
  point_in_time_recovery_enabled = try(each.value.point_in_time_recovery_enabled, false)
  server_side_encryption_enabled = try(each.value.server_side_encryption_enabled, true)
  
  tags = try(each.value.tags, {})
}

# 创建 Lambda 函数
module "lambda_function" {
  source   = "./modules/lambda_function"
  for_each = { for function in try(local.config.lambda_functions, []) : function.name => function }

  name             = each.key
  description      = try(each.value.description, "")
  handler          = each.value.handler
  runtime          = each.value.runtime
  role_arn         = each.value.role_arn
  
  # 源代码位置 (本地或 S3)
  filename         = try(each.value.filename, null)
  s3_bucket        = try(each.value.s3_bucket, null)
  s3_key           = try(each.value.s3_key, null)
  source_code_hash = try(each.value.source_code_hash, null)
  
  timeout          = try(each.value.timeout, 3)
  memory_size      = try(each.value.memory_size, 128)
  publish          = try(each.value.publish, false)
  
  environment_variables = try(each.value.environment, null)
  
  subnet_ids       = try(each.value.subnet_ids, [])
  security_group_ids = try(each.value.security_group_ids, [])
  
  tags = try(each.value.tags, {})
}

# 创建 VPC
module "vpc" {
  source   = "./modules/vpc"
  for_each = { for vpc in try(local.config.vpcs, []) : vpc.name => vpc }

  name               = each.key
  cidr_block         = each.value.cidr_block
  enable_dns_hostnames = try(each.value.enable_dns_hostnames, true)
  enable_dns_support = try(each.value.enable_dns_support, true)
  instance_tenancy   = try(each.value.instance_tenancy, "default")
  
  create_internet_gateway = try(each.value.create_internet_gateway, true)
  create_nat_gateway = try(each.value.create_nat_gateway, false)
  
  public_subnet_cidrs  = try(each.value.public_subnet_cidrs, [])
  private_subnet_cidrs = try(each.value.private_subnet_cidrs, [])
  availability_zones   = try(each.value.availability_zones, [])
  
  tags = try(each.value.tags, {})
}

# 输出创建的资源信息
output "s3_buckets" {
  value = { for k, v in module.s3_bucket : k => v.bucket_id }
}

output "ec2_instances" {
  value = { for k, v in module.ec2_instance : k => {
    id        = v.id
    public_ip = v.public_ip
    private_ip = v.private_ip
  } }
}

output "dynamodb_tables" {
  value = { for k, v in module.dynamodb_table : k => v.table_id }
}

output "lambda_functions" {
  value = { for k, v in module.lambda_function : k => v.function_name }
}

output "vpcs" {
  value = { for k, v in module.vpc : k => v.vpc_id }
}
