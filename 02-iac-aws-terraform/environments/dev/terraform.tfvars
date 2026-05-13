# ─── DEV ENVIRONMENT ───
environment            = "dev"
project_name           = "ayush-devops"
aws_region             = "us-east-1"
vpc_cidr               = "10.0.0.0/16"
eks_cluster_version    = "1.28"
eks_node_instance_type = "t3.medium"
eks_node_desired       = 1
eks_node_min           = 1
eks_node_max           = 3
db_name                = "devopsdb"
db_instance_class      = "db.t3.micro"
