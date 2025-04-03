locals {
  # 检查configs目录是否存在
  configs_dir_exists = fileexists("${path.root}/configs/lambda") || fileexists("${path.root}/configs/lambda/")
  
  # 获取configs/lambda目录中的所有YAML文件
  lambda_config_files = local.configs_dir_exists ? fileset("${path.root}/configs/lambda", "*.{yaml,yml}") : []
  
  # 将所有YAML配置文件读取并合并到一个映射中
  lambda_configs = {
    for config_file in local.lambda_config_files :
    trimsuffix(basename(config_file), parseint(regex("\\.ya?ml$", basename(config_file)), 10) == 0 ? ".yaml" : ".yml") => yamldecode(file("${path.root}/configs/lambda/${config_file}"))
  }
  
  # 当前Lambda函数的配置 (如果存在)
  current_lambda_config = contains(keys(local.lambda_configs), var.function_name) ? local.lambda_configs[var.function_name] : {}
  
  # 从YAML配置中提取各个配置项 (如果存在)，否则使用变量中的值
  yaml_function_name = try(local.current_lambda_config.function_name, null)
  yaml_description = try(local.current_lambda_config.description, null)
  yaml_handler = try(local.current_lambda_config.handler, null) 
  yaml_runtime = try(local.current_lambda_config.runtime, null)
  yaml_memory_size = try(local.current_lambda_config.memory_size, null)
  yaml_timeout = try(local.current_lambda_config.timeout, null)
  yaml_publish = try(local.current_lambda_config.publish, null)
  
  # 环境变量
  yaml_environment_variables = try(local.current_lambda_config.environment_variables, {})
  
  # VPC配置
  yaml_vpc_config = try(local.current_lambda_config.vpc_config, {})
  yaml_vpc_subnet_ids = try(local.yaml_vpc_config.subnet_ids, [])
  yaml_vpc_security_group_ids = try(local.yaml_vpc_config.security_group_ids, [])
  
  # 死信队列
  yaml_dead_letter_target_arn = try(local.current_lambda_config.dead_letter_target_arn, null)
  
  # 追踪
  yaml_tracing_mode = try(local.current_lambda_config.tracing_mode, null)
  
  # 层
  yaml_layers = try(local.current_lambda_config.layers, [])
  
  # 代码包配置
  yaml_package = try(local.current_lambda_config.package, {})
  yaml_package_type = try(local.yaml_package.type, null)
  yaml_source_path = try(local.yaml_package.source_path, null)
  yaml_s3_bucket = try(local.yaml_package.s3_bucket, null)
  yaml_s3_key = try(local.yaml_package.s3_key, null)
  
  # IAM角色配置
  yaml_create_role = try(local.current_lambda_config.create_role, null)
  yaml_lambda_role = try(local.current_lambda_config.lambda_role, null)
  
  # 策略配置
  yaml_policy_statements = try(local.current_lambda_config.policy_statements, {})
  
  # 最终值 - 优先使用变量中的值，如果未设置则使用YAML中的值
  final_function_name = coalesce(var.function_name, local.yaml_function_name)
  final_description = coalesce(var.description, local.yaml_description)
  final_handler = coalesce(var.handler, local.yaml_handler)
  final_runtime = coalesce(var.runtime, local.yaml_runtime)
  final_memory_size = coalesce(var.memory_size, local.yaml_memory_size)
  final_timeout = coalesce(var.timeout, local.yaml_timeout)
  final_publish = var.publish != null ? var.publish : local.yaml_publish
  
  # 最终环境变量 - 合并两个来源
  final_environment_variables = merge(local.yaml_environment_variables, var.environment_variables)
  
  # 最终VPC配置
  final_vpc_subnet_ids = length(var.vpc_subnet_ids) > 0 ? var.vpc_subnet_ids : local.yaml_vpc_subnet_ids
  final_vpc_security_group_ids = length(var.vpc_security_group_ids) > 0 ? var.vpc_security_group_ids : local.yaml_vpc_security_group_ids
  
  # 最终死信队列配置
  final_dead_letter_target_arn = coalesce(var.dead_letter_target_arn, local.yaml_dead_letter_target_arn)
  
  # 最终追踪配置
  final_tracing_mode = coalesce(var.tracing_mode, local.yaml_tracing_mode)
  
  # 最终层配置
  final_layers = distinct(concat(var.layers, local.yaml_layers))
  
  # 最终包配置
  final_package_type = coalesce(var.package_type, local.yaml_package_type)
  
  # 最终IAM角色配置
  final_create_role = var.create_role != null ? var.create_role : local.yaml_create_role
  final_lambda_role = coalesce(var.lambda_role, local.yaml_lambda_role)
}
