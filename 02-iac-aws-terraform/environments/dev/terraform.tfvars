# ============================================
# DEV ENVIRONMENT — Terraform Variables
# Usage:
#   terraform init
#   terraform workspace new dev
#   terraform plan -var-file=environments/dev/terraform.tfvars
#   terraform apply -var-file=environments/dev/terraform.tfvars
# ============================================

environment            = "dev"
project_name           = "ayush-devops"
aws_region             = "us-east-1"

# Network
vpc_cidr               = "10.0.0.0/16"

# EKS — dev mein small cluster
eks_cluster_version    = "1.28"
eks_node_instance_type = "t3.medium"
eks_node_desired       = 1
eks_node_min           = 1
eks_node_max           = 3

# RDS — dev mein minimal
db_name                = "devopsdb"
db_instance_class      = "db.t3.micro"
