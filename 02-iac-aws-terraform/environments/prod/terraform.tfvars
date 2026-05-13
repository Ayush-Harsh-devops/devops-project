# ─── PROD ENVIRONMENT ───
environment            = "prod"
project_name           = "ayush-devops"
aws_region             = "us-east-1"
vpc_cidr               = "10.1.0.0/16"
eks_cluster_version    = "1.28"
eks_node_instance_type = "t3.large"
eks_node_desired       = 3
eks_node_min           = 2
eks_node_max           = 10
db_name                = "devopsdb"
db_instance_class      = "db.t3.small"
