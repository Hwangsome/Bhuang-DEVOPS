variable "config_file" {
  description = "Path to the YAML configuration file that defines AWS resources"
  type        = string
  default     = "configs/resources.yaml"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Project   = "yaml-based-infrastructure"
  }
}
