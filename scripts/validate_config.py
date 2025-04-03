#!/usr/bin/env python3
"""
YAML 配置验证器
验证 AWS 资源配置文件的格式并提供错误反馈
"""

import argparse
import sys
import os
import yaml
import json
from typing import Dict, List, Any, Optional


def validate_s3_bucket(bucket: Dict[str, Any]) -> List[str]:
    """验证 S3 存储桶配置"""
    errors = []
    if 'name' not in bucket:
        errors.append("S3 bucket missing required 'name' field")
    elif not isinstance(bucket['name'], str):
        errors.append(f"S3 bucket name must be a string, got {type(bucket['name'])}")
    
    if 'tags' in bucket and not isinstance(bucket['tags'], dict):
        errors.append(f"S3 bucket tags must be a dictionary, got {type(bucket['tags'])}")
    
    return errors


def validate_ec2_instance(instance: Dict[str, Any]) -> List[str]:
    """验证 EC2 实例配置"""
    errors = []
    required_fields = ['name', 'ami', 'instance_type']
    
    for field in required_fields:
        if field not in instance:
            errors.append(f"EC2 instance missing required '{field}' field")
    
    if 'root_block_device' in instance:
        if not isinstance(instance['root_block_device'], dict):
            errors.append("EC2 root_block_device must be a dictionary")
    
    if 'tags' in instance and not isinstance(instance['tags'], dict):
        errors.append(f"EC2 instance tags must be a dictionary, got {type(instance['tags'])}")
    
    return errors


def validate_dynamodb_table(table: Dict[str, Any]) -> List[str]:
    """验证 DynamoDB 表配置"""
    errors = []
    required_fields = ['name', 'hash_key', 'attributes']
    
    for field in required_fields:
        if field not in table:
            errors.append(f"DynamoDB table missing required '{field}' field")
    
    if 'attributes' in table:
        if not isinstance(table['attributes'], list):
            errors.append("DynamoDB attributes must be a list")
        else:
            for i, attr in enumerate(table['attributes']):
                if 'name' not in attr:
                    errors.append(f"DynamoDB attribute at index {i} missing 'name' field")
                if 'type' not in attr:
                    errors.append(f"DynamoDB attribute at index {i} missing 'type' field")
                elif attr['type'] not in ['S', 'N', 'B']:
                    errors.append(f"DynamoDB attribute type must be one of ['S', 'N', 'B'], got '{attr['type']}'")
    
    return errors


def validate_lambda_function(function: Dict[str, Any]) -> List[str]:
    """验证 Lambda 函数配置"""
    errors = []
    required_fields = ['name', 'handler', 'runtime', 'role_arn']
    
    for field in required_fields:
        if field not in function:
            errors.append(f"Lambda function missing required '{field}' field")
    
    # Validate that either filename or s3 details are provided
    if 'filename' not in function and ('s3_bucket' not in function or 's3_key' not in function):
        errors.append("Lambda function must specify either 'filename' or both 's3_bucket' and 's3_key'")
    
    return errors


def validate_vpc(vpc: Dict[str, Any]) -> List[str]:
    """验证 VPC 配置"""
    errors = []
    required_fields = ['name', 'cidr_block']
    
    for field in required_fields:
        if field not in vpc:
            errors.append(f"VPC missing required '{field}' field")
    
    if 'cidr_block' in vpc:
        # Basic CIDR block validation
        cidr = vpc['cidr_block']
        if not isinstance(cidr, str) or not ('/' in cidr):
            errors.append(f"VPC CIDR block '{cidr}' is not in valid format (e.g., '10.0.0.0/16')")
    
    return errors


def validate_config(config: Dict[str, Any]) -> Dict[str, List[str]]:
    """验证整个配置文件"""
    all_errors = {}
    
    # 验证 S3 存储桶
    if 's3_buckets' in config:
        s3_errors = []
        if not isinstance(config['s3_buckets'], list):
            s3_errors.append("s3_buckets must be a list")
        else:
            for i, bucket in enumerate(config['s3_buckets']):
                errors = validate_s3_bucket(bucket)
                if errors:
                    s3_errors.append(f"Bucket at index {i}: {', '.join(errors)}")
        
        if s3_errors:
            all_errors['s3_buckets'] = s3_errors
    
    # 验证 EC2 实例
    if 'ec2_instances' in config:
        ec2_errors = []
        if not isinstance(config['ec2_instances'], list):
            ec2_errors.append("ec2_instances must be a list")
        else:
            for i, instance in enumerate(config['ec2_instances']):
                errors = validate_ec2_instance(instance)
                if errors:
                    ec2_errors.append(f"Instance at index {i}: {', '.join(errors)}")
        
        if ec2_errors:
            all_errors['ec2_instances'] = ec2_errors
    
    # 验证 DynamoDB 表
    if 'dynamodb_tables' in config:
        ddb_errors = []
        if not isinstance(config['dynamodb_tables'], list):
            ddb_errors.append("dynamodb_tables must be a list")
        else:
            for i, table in enumerate(config['dynamodb_tables']):
                errors = validate_dynamodb_table(table)
                if errors:
                    ddb_errors.append(f"Table at index {i}: {', '.join(errors)}")
        
        if ddb_errors:
            all_errors['dynamodb_tables'] = ddb_errors
    
    # 验证 Lambda 函数
    if 'lambda_functions' in config:
        lambda_errors = []
        if not isinstance(config['lambda_functions'], list):
            lambda_errors.append("lambda_functions must be a list")
        else:
            for i, function in enumerate(config['lambda_functions']):
                errors = validate_lambda_function(function)
                if errors:
                    lambda_errors.append(f"Function at index {i}: {', '.join(errors)}")
        
        if lambda_errors:
            all_errors['lambda_functions'] = lambda_errors
    
    # 验证 VPC
    if 'vpcs' in config:
        vpc_errors = []
        if not isinstance(config['vpcs'], list):
            vpc_errors.append("vpcs must be a list")
        else:
            for i, vpc in enumerate(config['vpcs']):
                errors = validate_vpc(vpc)
                if errors:
                    vpc_errors.append(f"VPC at index {i}: {', '.join(errors)}")
        
        if vpc_errors:
            all_errors['vpcs'] = vpc_errors
    
    return all_errors


def process_yaml(file_path: str, output_format: str = 'text') -> int:
    """处理 YAML 文件并验证其内容"""
    if not os.path.exists(file_path):
        print(f"Error: File not found: {file_path}", file=sys.stderr)
        return 1
    
    try:
        with open(file_path, 'r') as f:
            config = yaml.safe_load(f)
    except yaml.YAMLError as e:
        print(f"Error parsing YAML file: {e}", file=sys.stderr)
        return 1
    
    errors = validate_config(config)
    
    if errors:
        if output_format == 'json':
            print(json.dumps({'errors': errors}, indent=2))
        else:
            print("配置验证失败，发现以下错误:")
            for section, section_errors in errors.items():
                print(f"\n{section}:")
                for error in section_errors:
                    print(f"  - {error}")
        return 1
    else:
        if output_format == 'json':
            print(json.dumps({'valid': True}))
        else:
            print("配置验证成功！")
        return 0


def convert_to_tfvars(yaml_file: str, output_file: Optional[str] = None) -> int:
    """将 YAML 配置转换为 Terraform tfvars 格式"""
    try:
        with open(yaml_file, 'r') as f:
            config = yaml.safe_load(f)
    except yaml.YAMLError as e:
        print(f"Error parsing YAML file: {e}", file=sys.stderr)
        return 1
    
    # 创建包含文件路径的 tfvars 内容
    tfvars_content = f'config_file = "{yaml_file}"\n'
    
    # 如果指定了输出文件，写入内容
    if output_file:
        with open(output_file, 'w') as f:
            f.write(tfvars_content)
        print(f"Created Terraform variables file: {output_file}")
    else:
        print(tfvars_content)
    
    return 0


def main():
    parser = argparse.ArgumentParser(description="验证和处理 AWS 资源 YAML 配置文件")
    parser.add_argument("file", help="要处理的 YAML 配置文件")
    parser.add_argument("--format", choices=["text", "json"], default="text",
                        help="输出格式 (默认: text)")
    parser.add_argument("--convert", action="store_true",
                        help="将 YAML 转换为 Terraform tfvars 格式")
    parser.add_argument("--output", help="输出文件路径 (仅用于 --convert)")
    
    args = parser.parse_args()
    
    if args.convert:
        return convert_to_tfvars(args.file, args.output)
    else:
        return process_yaml(args.file, args.format)


if __name__ == "__main__":
    sys.exit(main())
