# # =====================================================================
# # AWS WAF (Preventative Control)
# # =====================================================================

# # 1. Define the Web Application Firewall (WebACL)
# resource "aws_wafv2_web_acl" "main_waf" {
#   name        = "${var.environment}-preventative-waf"
#   description = "WAF to prevent malicious L7 traffic to the Kubernetes app"
#   scope       = "REGIONAL"

#   default_action {
#     allow {} # Default action is to allow traffic unless a rule matches
#   }

#   # Add AWS Managed Core Rule Set (Blocks common exploits like XSS, SQLi)
#   rule {
#     name     = "AWS-AWSManagedRulesCommonRuleSet"
#     priority = 1

#     override_action {
#       none {}
#     }

#     statement {
#       managed_rule_group_statement {
#         name        = "AWSManagedRulesCommonRuleSet"
#         vendor_name = "AWS"
#       }
#     }

#     visibility_config {
#       cloudwatch_metrics_enabled = true
#       metric_name                = "AWSManagedRulesCommonRuleSetMetric"
#       sampled_requests_enabled   = true
#     }
#   }

#   visibility_config {
#     cloudwatch_metrics_enabled = true
#     metric_name                = "MainWAFMetric"
#     sampled_requests_enabled   = true
#   }
# }

# # 2. Look up the ALB created by the Kubernetes Ingress Controller
# # (EKS Ingress provisions the ALB with specific tags. We filter by the cluster name).
# data "aws_lb" "k8s_alb" {
#   tags = {
#     "kubernetes.io/cluster/${var.environment}-cluster" = "owned"
#   }
  
#   # Ensure Terraform waits for the ALB controller to be installed first
#   depends_on = [helm_release.aws_alb_controller]
# }

# # 3. Attach the WAF to the Application Load Balancer
# resource "aws_wafv2_web_acl_association" "waf_alb_association" {
#   resource_arn = data.aws_lb.k8s_alb.arn
#   web_acl_arn  = aws_wafv2_web_acl.main_waf.arn
# }