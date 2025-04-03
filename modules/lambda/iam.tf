# IAM role for Lambda function
resource "aws_iam_role" "lambda" {
  count = local.create && var.create_role ? 1 : 0

  name                  = var.role_name != null ? var.role_name : "${var.function_name}-role"
  description           = var.role_description
  path                  = var.role_path
  force_detach_policies = var.role_force_detach_policies
  permissions_boundary  = var.role_permissions_boundary
  assume_role_policy    = data.aws_iam_policy_document.assume_role[0].json

  tags = var.tags
}

# Trust relationship policy document for Lambda role
data "aws_iam_policy_document" "assume_role" {
  count = local.create && var.create_role ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = concat(["lambda.amazonaws.com"], var.lambda_at_edge ? ["edgelambda.amazonaws.com"] : [])
    }
  }
}

# Attach CloudWatch Logs policy to Lambda role
resource "aws_iam_policy" "logs" {
  count = local.create && var.create_role && var.attach_cloudwatch_logs_policy ? 1 : 0

  name        = "${var.function_name}-logs"
  description = "IAM policy for logging from Lambda"
  path        = var.role_path
  policy      = data.aws_iam_policy_document.logs[0].json

  tags = var.tags
}

# CloudWatch Logs policy document
data "aws_iam_policy_document" "logs" {
  count = local.create && var.create_role && var.attach_cloudwatch_logs_policy ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.function_name}:*",
    ]
  }
}

# Attach CloudWatch Logs policy to Lambda role
resource "aws_iam_role_policy_attachment" "logs" {
  count = local.create && var.create_role && var.attach_cloudwatch_logs_policy ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = aws_iam_policy.logs[0].arn
}

# Attach VPC policy to Lambda role
resource "aws_iam_policy" "vpc" {
  count = local.create && var.create_role && var.attach_network_policy ? 1 : 0

  name        = "${var.function_name}-vpc"
  description = "IAM policy for Lambda VPC access"
  path        = var.role_path
  policy      = data.aws_iam_policy_document.vpc[0].json

  tags = var.tags
}

# VPC policy document
data "aws_iam_policy_document" "vpc" {
  count = local.create && var.create_role && var.attach_network_policy ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:AssignPrivateIpAddresses",
      "ec2:UnassignPrivateIpAddresses"
    ]
    resources = ["*"]
  }
}

# Attach VPC policy to Lambda role
resource "aws_iam_role_policy_attachment" "vpc" {
  count = local.create && var.create_role && var.attach_network_policy ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = aws_iam_policy.vpc[0].arn
}

# Attach dead letter policy to Lambda role
resource "aws_iam_policy" "dead_letter" {
  count = local.create && var.create_role && var.attach_dead_letter_policy ? 1 : 0

  name        = "${var.function_name}-dl"
  description = "IAM policy for dead letter configuration"
  path        = var.role_path
  policy      = data.aws_iam_policy_document.dead_letter[0].json

  tags = var.tags
}

# Dead letter policy document
data "aws_iam_policy_document" "dead_letter" {
  count = local.create && var.create_role && var.attach_dead_letter_policy ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sqs:SendMessage"
    ]
    resources = [var.dead_letter_target_arn]
  }
}

# Attach dead letter policy to Lambda role
resource "aws_iam_role_policy_attachment" "dead_letter" {
  count = local.create && var.create_role && var.attach_dead_letter_policy ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = aws_iam_policy.dead_letter[0].arn
}

# Attach X-Ray tracing policy to Lambda role
resource "aws_iam_policy" "tracing" {
  count = local.create && var.create_role && var.attach_tracing_policy ? 1 : 0

  name        = "${var.function_name}-tracing"
  description = "IAM policy for Lambda X-Ray tracing"
  path        = var.role_path
  policy      = data.aws_iam_policy_document.tracing[0].json

  tags = var.tags
}

# X-Ray tracing policy document
data "aws_iam_policy_document" "tracing" {
  count = local.create && var.create_role && var.attach_tracing_policy ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries"
    ]
    resources = ["*"]
  }
}

# Attach X-Ray tracing policy to Lambda role
resource "aws_iam_role_policy_attachment" "tracing" {
  count = local.create && var.create_role && var.attach_tracing_policy ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = aws_iam_policy.tracing[0].arn
}

# Attach policies to Lambda role
resource "aws_iam_role_policy_attachment" "additional_policies" {
  for_each = { for k, v in var.attach_policy_arns : k => v if local.create && var.create_role }

  role       = aws_iam_role.lambda[0].name
  policy_arn = each.value
}

# Create custom policy and attach to Lambda role
resource "aws_iam_policy" "additional_policies" {
  for_each = { for k, v in var.attach_policy_json : k => v if local.create && var.create_role }

  name        = "${var.function_name}-${each.key}"
  description = "IAM policy for Lambda function ${var.function_name} (${each.key})"
  path        = var.role_path
  policy      = each.value

  tags = var.tags
}

# Attach custom policies to Lambda role
resource "aws_iam_role_policy_attachment" "additional_policies_json" {
  for_each = { for k, v in aws_iam_policy.additional_policies : k => v.arn if local.create && var.create_role }

  role       = aws_iam_role.lambda[0].name
  policy_arn = each.value
}

# IAM策略文档
data "aws_iam_policy_document" "additional_inline" {
  count = local.create_role && (var.attach_policy_statements || length(local.yaml_policy_statements) > 0) ? 1 : 0

  # 处理直接传入的策略声明
  dynamic "statement" {
    for_each = var.policy_statements

    content {
      sid           = try(statement.value.sid, replace(statement.key, "/[^0-9A-Za-z]*/", ""))
      effect        = try(statement.value.effect, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])
        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.condition, [])
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
  
  # 处理从YAML配置中读取的策略声明
  dynamic "statement" {
    for_each = local.yaml_policy_statements

    content {
      sid           = try(statement.value.sid, replace(statement.key, "/[^0-9A-Za-z]*/", ""))
      effect        = try(statement.value.effect, null)
      actions       = try(statement.value.actions, null)
      not_actions   = try(statement.value.not_actions, null)
      resources     = try(statement.value.resources, null)
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])
        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.condition, [])
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

# 应用从YAML和变量中解析的内联策略
resource "aws_iam_role_policy" "additional_inline" {
  count = local.create_role && (var.attach_policy_statements || length(local.yaml_policy_statements) > 0) ? 1 : 0

  name   = "${local.policy_name}-inline"
  role   = aws_iam_role.lambda[0].name
  policy = data.aws_iam_policy_document.additional_inline[0].json
}

# Add partition data source
data "aws_partition" "current" {}
