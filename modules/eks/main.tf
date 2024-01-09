data "aws_availability_zones" "available" {}

# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "dev-ops-sandbox-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

# EKS Node Group IAM Role
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group_role.name
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name                   = local.name
  cluster_version                = "1.28"
  cluster_endpoint_public_access = true
  vpc_id                         = var.vpc_id
  subnet_ids                     = var.private_subnets

  # If you don't have a specific key pair, remove the key_name argument
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }
  # very important to allow sg to add LoadBalancer
  node_security_group_tags = {
    "kubernetes.io/cluster/${local.name}" = null
  }

  tags = {
    "Environment" = "Production"
    "Project"     = "dev-ops-sandbox-role"
    
  }
}

module "node_group_private" {
  source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  name            = "private"
  cluster_name    = module.eks.cluster_name
  cluster_version = module.eks.cluster_version

  subnet_ids = var.private_subnets
  
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids            = [module.eks.node_security_group_id]

  max_size     = 3
  min_size     = 1
  desired_size = 2

  instance_types = ["t3a.medium"]
  capacity_type  = "ON_DEMAND"

  labels = {
    AccessSpecifier = "private"
    
  }
}