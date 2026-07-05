module "ec2" {
  source                = "./modules/ec2"
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_id      = module.vpc.public_subnets[0]
  allowed_ingress_cidrs = module.vpc.private_subnets_cidr_blocks
  backup_bucket_name    = module.s3.bucket_name
}