module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true

  vpc_id                   = aws_vpc.main.id
  subnet_ids               = aws_subnet.private[*].id
  control_plane_subnet_ids = aws_subnet.private[*].id

  eks_managed_node_groups = {
    stateless = {
      min_size       = 2
      max_size       = 8
      desired_size   = 2

      instance_types = ["t3.medium", "t3a.medium"]
      capacity_type  = "SPOT"

      labels = {
        workload-type = "stateless"
      }
    }

    redis = {
      min_size       = 1
      max_size       = 1
      desired_size   = 1

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      labels = {
        workload-type = "stateful"
        component     = "redis"
      }

      taints = [{
        key    = "workload"
        value  = "redis"
        effect = "NO_SCHEDULE"
      }]
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

data "aws_eks_cluster" "traific" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "traific" {
  name = module.eks.cluster_name
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.traific.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.traific.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.traific.token
  load_config_file       = false
}
