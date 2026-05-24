# ============================================
# MAIN TERRAFORM - AWS Infrastructure 
# Author: Ayush Harsh
# ============================================ 

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
  }

  backend "s3" {
    bucket         = "ayush-harsh-terraform-state"
    key            = "devops-project/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "DevOps-Real-Time"
      Owner       = "Ayush-Harsh"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  vpc_cidr     = var.vpc_cidr
}

module "eks" {
  source          = "./modules/eks"
  project_name    = var.project_name
  environment     = var.environment
  cluster_version = var.eks_cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  depends_on      = [module.vpc]
}

module "rds" {
  source       = "./modules/rds"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids
  db_name      = var.db_name
  db_username  = var.db_username
  depends_on   = [module.vpc]
}
