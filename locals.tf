locals {
  cluster_name = "test-eks-cluster-${var.name}"
  db_creds = yamldecode(data.aws_kms_secrets.creds.plaintext["db"])
}