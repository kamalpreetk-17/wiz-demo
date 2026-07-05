module "ecr" {
  source          = "../modules/ecr"
  environment     = var.environment
  repository_name = "wiz-demo-app" 
}