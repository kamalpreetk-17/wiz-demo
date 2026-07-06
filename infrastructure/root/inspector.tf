data "aws_caller_identity" "current" {}

resource "aws_inspector2_enabler" "main" {
  account_ids = [data.aws_caller_identity.current.account_id]
  
  # EC2 covers your worker nodes, ECR covers your container registries
  resource_types = ["EC2", "ECR"]
}