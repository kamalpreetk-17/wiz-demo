# =====================================================================
# AWS CloudTrail (Control Plane Audit Logging Requirement)
# =====================================================================

data "aws_caller_identity" "current" {}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket        = "${var.environment}-cloudtrail-logs-${random_string.suffix.result}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck",
        Effect = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action   = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.cloudtrail_bucket.arn
      },
      {
        Sid    = "AWSCloudTrailWrite",
        Effect = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.cloudtrail_bucket.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Condition = { StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" } }
      }
    ]
  })
}

resource "aws_cloudtrail" "main_trail" {
  name                          = "${var.environment}-audit-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  depends_on                    = [aws_s3_bucket_policy.cloudtrail_policy]
}