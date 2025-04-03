resource "aws_s3_bucket" "this" {
  bucket = var.name

  tags = var.tags
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = var.object_ownership
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

# 条件性创建存储桶策略
resource "aws_s3_bucket_policy" "this" {
  count = var.policy != null ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = var.policy
}

# 条件性启用版本控制
resource "aws_s3_bucket_versioning" "this" {
  count = var.enable_versioning ? 1 : 0

  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 条件性配置加密
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = var.encryption_enabled ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
  }
}
