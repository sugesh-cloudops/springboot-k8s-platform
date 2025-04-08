resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
  depends_on = [aws_iam_role_policy_attachment.cluster_policy]
}
resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_role_policy_attachment" "node_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ])

  policy_arn = each.value
  role       = aws_iam_role.node.name
}
resource "aws_eks_node_group" "main" {
  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids

  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type
scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policy
  ]
}
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["d89e3bd43d5d909b47a18977aa9d5ce36cee184c"]
}

resource "aws_iam_role" "github_actions" {
  name = "GitHubActions-EKS-Deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
       
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::535002870929:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          "StringEquals": {
            "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          },
          "StringLike": {
            "token.actions.githubusercontent.com:sub": "repo:sugesh-cloudops/devops-coding-challenge:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_eks_access" {
  name        = "GitHubEKSAccessPolicy"
  description = "Allow GitHub Actions to assume the EKS role and interact with Kubernetes"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Allow assuming the GitHubActions-EKS-Deploy role
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = "arn:aws:iam::535002870929:role/GitHubActions-EKS-Deploy"
      },

      # Allow EKS access
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:AccessKubernetesApi",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:DescribeFargateProfile"
        ]
        Resource = "*"
      },

      # Allow IAM role management for GitHubActions-EKS-Deploy
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:PassRole",
          "iam:LisOpenIDConnectProviders",
          "iam:GetOpenIDConnectProvider"
        ]
        Resource = "arn:aws:iam::535002870929:role/GitHubActions-EKS-Deploy"
      },

      # Allow interaction with Kubernetes resources
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeRules",
          "eks:ListTagsForResource"
        ]
        Resource = "*"
      },

      # Allow read-only access to logs for debugging
      {
        Effect = "Allow"
        Action = [
          "logs:GetLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_eks_attach" {
  policy_arn = aws_iam_policy.github_eks_access.arn
  role       = aws_iam_role.github_actions.name
}