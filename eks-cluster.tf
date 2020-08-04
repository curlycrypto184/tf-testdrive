module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  subnets      = module.vpc.private_subnets

  tags = {
    Environment = "training"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
    Project = "Lithops"
  }

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t2.medium"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# Prometheus EBS/PV/PVC

resource "aws_ebs_volume" "lithops-prometheus" {
  availability_zone = "us-west-2a"
  size              = 20
  tags = {
    Name = "lithops-prometheus"
    Project = "Lithops"
  }
}

resource "kubernetes_persistent_volume" "lithops-prometheus" {
  metadata {
    name = "lithops-prometheus"
  }
  spec {
    capacity = {
      storage = "20Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = aws_ebs_volume.lithops-prometheus.id
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume_claim" "lithops-prometheus" {
  metadata {
    name = "lithops-prometheus"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
    selector {
      match_labels = {
        "name" = kubernetes_persistent_volume.lithops-prometheus.metadata.0.name
      }
    }
    storage_class_name = "standard"
    volume_name = kubernetes_persistent_volume.lithops-prometheus.metadata.0.name
  }
}

# Kubernetes EBS/PV/PVC

resource "aws_ebs_volume" "lithops-nfs" {
  availability_zone = "us-west-2a"
  size              = 20
  tags = {
    Name = "lithops-nfs"
    Project = "Lithops"
  }
}


resource "kubernetes_persistent_volume" "lithops-nfs" {
  metadata {
    name = "lithops-nfs"
  }
  spec {
    capacity = {
      storage = "20Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = aws_ebs_volume.lithops-nfs.id
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume_claim" "lithops-nfs" {
  metadata {
    name = "lithops-nfs"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
    selector {
      match_labels = {
        "name" = kubernetes_persistent_volume.lithops-nfs.metadata.0.name
      }
    }
    storage_class_name = "standard"
    volume_name = kubernetes_persistent_volume.lithops-nfs.metadata.0.name
  }
}
