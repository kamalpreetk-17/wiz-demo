variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_id" { type = string }
variable "allowed_ingress_cidrs" { type = list(string) }
variable "backup_bucket_name" { type = string }

variable "k8s_node_security_group_id" {
  type    = string
  default = null
}