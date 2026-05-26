# ============================================
# PROD ENVIRONMENT — Terraform Variables
# Usage:
#   terraform workspace new prod
#   terraform plan -var-file=environments/prod/terraform.tfvars
#   terraform apply -var-file=environments/prod/terraform.tfvars -auto-approve
# WARNING: Production — changes affect live traffic!
# ============================================

environment            = "prod"
project_name           = "ayush-devops"
aws_region             = "us-east-1"

# Network — alag CIDR dev se
vpc_cidr               = "10.1.0.0/16"

# EKS — prod mein bada cluster
eks_cluster_version    = "1.28"
eks_node_instance_type = "t3.large"
eks_node_desired       = 3
eks_node_min           = 2
eks_node_max           = 10

# RDS — prod mein Multi-AZ
db_name                = "devopsdb"
db_instance_class      = "db.t3.small"
