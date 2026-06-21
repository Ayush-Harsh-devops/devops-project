# ============================================
# MAIN TERRAFORM — AWS Infrastructure
# Author: Ayush Harsh
# ==============================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Remote state — S3 + DynamoDB lock
  backend "s3" {
    bucket         = "ayush-harsh-terraform-state"
    key            = "devops-project/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"

    # State file versioning
    versioning = true
  }
}

# ============================================
# Provider
# ============================================
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "DevOps-Real-Time"
      Owner       = "Ayush-Harsh"
      ManagedBy   = "Terraform"
      Environment = var.environment
      CostCenter  = "devops-team"
      Repo        = "github.com/Ayush-Harsh-devops/devops-project"
    }
  }
}

# ============================================
# Local Values
# ============================================
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================
# VPC Module
# ============================================
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  vpc_cidr     = var.vpc_cidr
}

# ============================================
# EKS Module
# ============================================
module "eks" {
  source = "./modules/eks"

  project_name           = var.project_name
  environment            = var.environment
  cluster_version        = var.eks_cluster_version
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.private_subnet_ids
  node_instance_type     = var.eks_node_instance_type
  node_desired           = var.eks_node_desired
  node_min               = var.eks_node_min
  node_max               = var.eks_node_max

  depends_on = [module.vpc]
}

# ============================================
# RDS Module
# ============================================
module "rds" {
  source = "./modules/rds"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  db_name           = var.db_name
  db_username       = var.db_username
  db_instance_class = var.db_instance_class

  depends_on = [module.vpc]
}

# ============================================
# Outputs
# ============================================
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}
