# ============================================
# EKS MODULE — Production Grade
# ============================================

# ── EKS Cluster ──────────────────────────────
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-${var.environment}-eks"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  # Enable all control plane logs
  enabled_cluster_log_types = [
    "api", "audit", "authenticator",
    "controllerManager", "scheduler"
  ]

  # Encrypt secrets at rest
  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks.arn
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-eks"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_cloudwatch_log_group.eks
  ]
}

# ── KMS Key for EKS Secrets ──────────────────
resource "aws_kms_key" "eks" {
  description             = "EKS secrets encryption — ${var.project_name}-${var.environment}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-kms"
  }
}

# ── CloudWatch Log Group ─────────────────────
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.project_name}-${var.environment}/cluster"
  retention_in_days = 30
}

# ── EKS Node Group ───────────────────────────
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-${var.environment}-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.subnet_ids
  instance_types  = [var.node_instance_type]
  capacity_type   = var.environment == "prod" ? "ON_DEMAND" : "SPOT"

  scaling_config {
    desired_size = var.node_desired
    min_size     = var.node_min
    max_size     = var.node_max
  }

  update_config {
    max_unavailable = 1
  }

  # Auto-update node AMI
  release_version = null

  labels = {
    Environment = var.environment
    Project     = var.project_name
    NodeGroup   = "main"
  }

  tags = {
    Name                                                          = "${var.project_name}-${var.environment}-nodes"
    "k8s.io/cluster-autoscaler/enabled"                          = "true"
    "k8s.io/cluster-autoscaler/${var.project_name}-${var.environment}-eks" = "owned"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy,
  ]
}

# ── IAM: EKS Cluster Role ────────────────────
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# ── IAM: EKS Nodes Role ──────────────────────
resource "aws_iam_role" "eks_nodes" {
  name = "${var.project_name}-${var.environment}-eks-nodes-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# ── Outputs ───────────────────────────────────
output "cluster_name"     { value = aws_eks_cluster.main.name }
output "cluster_endpoint" { value = aws_eks_cluster.main.endpoint }
output "cluster_ca"       { value = aws_eks_cluster.main.certificate_authority[0].data }
output "kms_key_arn"      { value = aws_kms_key.eks.arn }
