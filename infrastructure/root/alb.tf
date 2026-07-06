data "aws_caller_identity" "current" {}

locals {
  # This safely extracts the raw OIDC URL without relying on module wrapper outputs
  raw_oidc_url = try(module.eks.cluster_oidc_issuer_url, "")
}

module "load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                              = "${module.eks.cluster_name}-alb-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      # Bypassing the buggy output and building the ARN manually:
      provider_arn               = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(local.raw_oidc_url, "https://", "")}"
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

# AWS Load Balancer Controller
resource "helm_release" "aws_alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  values = [<<EOF
clusterName: ${module.eks.cluster_name}
vpcId: ${module.vpc.vpc_id}
serviceAccount:
  create: true
  name: aws-load-balancer-controller
  annotations:
    "eks.amazonaws.com/role-arn": ${module.load_balancer_controller_irsa_role.iam_role_arn}
EOF
  ]

   depends_on = [module.eks] 
}




