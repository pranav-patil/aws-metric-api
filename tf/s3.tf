resource "aws_s3_bucket" "serverless_state_bucket" {
  bucket        = "nssi-sls-deployment"
  force_destroy = true
  tags = {
    Name = "nssi-sls-deployment"
  }
}

resource "aws_s3_bucket_public_access_block" "serverless_state_bucket_access_block" {
  bucket = aws_s3_bucket.serverless_state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "serverless_state" {
  bucket = aws_s3_bucket.serverless_state_bucket.id
  acl    = "private"
}

#resource "aws_s3_bucket_server_side_encryption_configuration" "serverless_state_bucket_encryption" {
#  bucket = aws_s3_bucket.serverless_state_bucket.id
#
#  rule {
#    apply_server_side_encryption_by_default {
#      kms_master_key_id = aws_kms_key.s3_key.arn
#      sse_algorithm     = "aws:kms"
#    }
#  }
#}

resource "aws_ssm_parameter" "serverless_state_bucket_name" {
  name        = "serverless-s3-bucket"
  description = "Serverless deployment bucket name"
  type        = "String"
  value       = aws_s3_bucket.serverless_state_bucket.bucket
}

resource "aws_s3_bucket" "metric_data_athena_bucket" {
  bucket        = "${var.cluster_name}-metric-data-athena-bucket"
  force_destroy = true
  tags = {
    Name        = "${var.cluster_name}-metric-data-athena-bucket"
    Environment = var.env
  }
}

resource "aws_s3_bucket_acl" "audit_logs_bucket_acl" {
  bucket = aws_s3_bucket.metric_data_athena_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "audit_logs_bucket_lifecycle" {
  bucket = aws_s3_bucket.metric_data_athena_bucket.id

  rule {
    id     = "audit_logs_bucket_lifecycle"
    status = "Enabled"

    expiration {
      days = 10
    }
  }
}

resource "aws_s3_bucket" "audit_logs_backup_bucket" {
  bucket        = "${var.cluster_name}-audit-logs-backup-bucket"
  force_destroy = true
  tags = {
    Name        = "${var.cluster_name}-audit-logs-backup-bucket"
    Environment = var.env
  }
}

resource "aws_s3_bucket_acl" "audit_logs_backup_bucket_acl" {
  bucket = aws_s3_bucket.audit_logs_backup_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "audit_logs_backup_bucket_lifecycle" {
  bucket = aws_s3_bucket.audit_logs_backup_bucket.id

  rule {
    id     = "audit_logs_backup_bucket_lifecycle"
    status = "Enabled"

    expiration {
      days = 1
    }
  }
}
