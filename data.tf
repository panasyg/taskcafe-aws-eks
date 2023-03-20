data "aws_availability_zones" "available" {}

data "aws_kms_secrets" "creds" {
  secret {
    name    = "db"
    payload = file("${path.module}/creds/db-creds.yml.encrypted")
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
