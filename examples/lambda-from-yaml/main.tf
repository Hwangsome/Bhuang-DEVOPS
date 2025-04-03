provider "aws" {
  region = "us-east-1"
}

# 使用YAML配置的Lambda函数
module "lambda_function_from_yaml" {
  source = "../../modules/lambda"

  # 只需提供函数名称，它会自动从configs/lambda/api-gateway-function.yaml加载配置
  function_name = "api-gateway-function"
  
  # 如果需要，这里的值会覆盖YAML中的配置
  # memory_size = 1024  # 覆盖YAML中的内存配置
  
  # 可以添加不在YAML中定义的其他配置
  tags = {
    Environment = "Production"
    Project     = "API Gateway Integration"
  }
}

# 另一个使用YAML配置的Lambda函数
module "lambda_function_from_yaml2" {
  source = "../../modules/lambda"

  # 使用configs/lambda/example-function.yaml的配置
  function_name = "example-function"
}

# 不使用YAML配置的Lambda函数 - 完全使用Terraform参数
module "lambda_function_direct" {
  source = "../../modules/lambda"

  function_name = "manual-lambda-function"
  description   = "Lambda function configured directly in Terraform"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  
  environment_variables = {
    ENV = "development"
  }
}

# 输出
output "lambda_function_from_yaml_arn" {
  description = "通过YAML配置的Lambda函数ARN"
  value       = module.lambda_function_from_yaml.lambda_function_arn
}

output "lambda_function_from_yaml2_arn" {
  description = "通过YAML配置的Lambda函数2 ARN"
  value       = module.lambda_function_from_yaml2.lambda_function_arn
}

output "lambda_function_direct_arn" {
  description = "直接配置的Lambda函数ARN"
  value       = module.lambda_function_direct.lambda_function_arn
}
