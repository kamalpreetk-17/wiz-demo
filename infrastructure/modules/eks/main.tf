module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name                   = "${var.environment}-cluster"
  cluster_version                = "1.28"
  vpc_id                         = var.vpc_id
  subnet_ids                     = var.private_subnets
  control_plane_subnet_ids       = var.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    wiz_nodes = { min_size = 1, max_size = 2, desired_size = 1, instance_types = ["t3.medium"] }
  }
}