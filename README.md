# AWS Resource Provisioner

使用 Terraform 和 YAML 配置来创建 AWS 资源的项目。

## 概述

这个项目允许您通过 YAML 配置文件定义 AWS 资源，然后使用 Terraform 进行创建和管理。YAML 文件作为参数传递给 Terraform，简化了资源管理和配置过程。

## 使用方法

1. 创建一个 YAML 配置文件 (例如 `resources.yaml`)，定义您想要创建的 AWS 资源
2. 使用以下命令运行 Terraform：

```bash
terraform init
terraform plan -var="config_file=resources.yaml"
terraform apply -var="config_file=resources.yaml"
```

## 目录结构

```
.
├── README.md               # 项目文档
├── main.tf                 # 主 Terraform 配置
├── variables.tf            # 变量定义
├── terraform.tfvars        # 默认变量值
├── modules/                # Terraform 模块目录
│   └── ...
├── configs/                # YAML 配置文件目录
│   ├── resources.yaml      # 示例资源配置
│   └── ...
└── scripts/                # 辅助脚本
    └── ...
```

## 支持的资源类型

- EC2 实例
- S3 存储桶
- DynamoDB 表
- Lambda 函数
- 等等...

## 示例配置

参见 `configs/resources.yaml` 获取完整示例。

## 环境要求

- Terraform >= 1.0.0
- AWS CLI 已配置
- Python >= 3.6 (用于辅助脚本)
# Bhuang-DEVOPS
