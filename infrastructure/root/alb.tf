# AWS Load Balancer Controller
resource "helm_release" "aws_alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  values = [<<EOF
clusterName: ${module.eks.cluster_name}
vpcId: ${module.vpc.vpc_id}
EOF
  ]
}