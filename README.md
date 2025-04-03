# AWS Resource Provisioner

使用 Terraform 和 YAML 配置来创建 AWS 资源的项目。

## 概述

这个项目允许您通过 YAML 配置文件定义 AWS 资源，然后使用 Terraform 进行创建和管理。YAML 文件作为参数传递给 Terraform，简化了资源管理和配置过程。

## 使用方法

### 本地执行

1. 创建一个 YAML 配置文件，放置在 `configs` 目录下，文件命名格式为 `<CONTEXT>.<REGION>.<LAYER_IDENTIFIER>.yml`
2. 设置环境变量或使用默认值:
   - `TEAMCITY_WORK_DIR`: 工作目录（默认为当前目录）
   - `CONTEXT`: 环境上下文，如 dev, staging, prod（默认为 dev）
   - `REGION`: AWS 区域（默认为 us-west-1）
   - `LAYER_IDENTIFIER`: 基础设施层（默认为 infra）
3. 使用脚本执行 Terraform 操作:

```bash
# 初始化 Terraform
./scripts/terraform_init.sh

# 规划变更
./scripts/terraform_plan.sh

# 应用变更
./scripts/terraform_apply.sh

# 销毁资源
./scripts/terraform_destroy.sh
```

示例:

```bash
CONTEXT=prod REGION=eu-west-1 LAYER_IDENTIFIER=database ./scripts/terraform_plan.sh
```

### 通过 GitHub Actions 执行

本项目配置了 GitHub Actions 工作流程，可以自动化执行 Terraform 操作:

1. **部署工作流** (`terraform-deploy.yml`):
   - 自动触发: 向 main/master 分支推送代码或创建 Pull Request
   - 手动触发: 在 GitHub 界面中手动运行工作流，可以指定操作类型、环境上下文、区域和层标识符

2. **销毁工作流** (`terraform-destroy.yml`):
   - 仅支持手动触发
   - 需要输入 "DESTROY" 确认销毁操作
   - 可以指定环境上下文、区域和层标识符

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
│   ├── dev.us-west-1.infra.yml   # 示例配置
│   └── ...
├── scripts/                # Terraform 操作脚本
│   ├── terraform_init.sh   # 初始化脚本
│   ├── terraform_plan.sh   # 规划脚本
│   ├── terraform_apply.sh  # 应用脚本
│   └── terraform_destroy.sh # 销毁脚本
└── .github/                # GitHub 配置
    └── workflows/          # GitHub Actions 工作流
        ├── terraform-deploy.yml  # 部署工作流
        └── terraform-destroy.yml # 销毁工作流
```

## Terraform 脚本说明

项目中包含以下脚本，用于执行不同的 Terraform 操作:

1. **terraform_init.sh**: 初始化 Terraform 工作目录，读取 YAML 配置文件
2. **terraform_plan.sh**: 创建执行计划，显示 Terraform 将执行的操作
3. **terraform_apply.sh**: 应用执行计划，创建或更新基础设施
4. **terraform_destroy.sh**: 销毁由 Terraform 管理的基础设施

所有脚本都使用统一的 YAML 配置文件命名格式:
```
${TEAMCITY_WORK_DIR}/configs/${CONTEXT}.${REGION}.${LAYER_IDENTIFIER}.yml
```

## GitHub Actions 工作流程

### 部署工作流

部署工作流程可以通过三种方式触发:

1. 向 main/master 分支推送代码（安全模式，仅执行 plan）
2. 创建 Pull Request 到 main/master 分支（安全模式，仅执行 plan）
3. 手动触发，可以选择执行 init、plan 或 apply 操作

手动触发时可以指定以下参数:
- 操作类型: init、plan 或 apply
- 环境上下文: dev、staging、prod 等
- AWS 区域
- 层标识符: 定义基础设施层，如 infra、database、networking 等

### 销毁工作流

销毁工作流仅支持手动触发，并要求确认:

1. 在 GitHub Actions 界面中选择 "Terraform Destroy" 工作流
2. 指定环境上下文、区域和层标识符
3. 在确认框中输入 "DESTROY" 确认操作

## 支持的资源类型

- EC2 实例
- S3 存储桶
- DynamoDB 表
- Lambda 函数
- 等等...

## 环境要求

- Terraform >= 1.0.0
- AWS CLI 已配置
- Python >= 3.6 (用于辅助脚本)
# Bhuang-DEVOPS
