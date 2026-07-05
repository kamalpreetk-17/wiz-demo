output "mongodb_private_ip" { 
    value = module.ec2.private_ip 
}

output "mongodb_public_ssh_ip" { 
    value = module.ec2.public_ip 
}

output "public_backup_bucket" { 
    value = module.s3.bucket_name 
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}