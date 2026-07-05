terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 5.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.0" }
    helm       = { source = "hashicorp/helm", version = "~> 2.0" }
  }
}

provider "aws" { 
  region = var.aws_region 

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "Wiz-Technical-Exercise"
      ManagedBy   = "Terraform"
      Owner       = "Kamalpreet_Kaur" 
    }
  }

}

# Configure Helm provider using outputs from the EKS module to install the ALB Controller
# 1. Fetch the authentication token natively using Terraform
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

# 2. Configure Helm using the native token
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}