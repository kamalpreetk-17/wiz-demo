# AWS IAM Access Analyzer (Detects public S3 buckets and exposed IAM)
resource "aws_accessanalyzer_analyzer" "main" {
  analyzer_name = "${var.environment}-access-analyzer"
  type          = "ACCOUNT"
}