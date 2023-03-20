module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = "${var.name}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  create_database_subnet_group = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.24.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.24"
  subnets         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group"
      instance_type                 = "t2.medium"
      additional_userdata           = "echo nothing"
      additional_security_group_ids = [module.security-group.security_group_id]
      asg_desired_capacity          = 3
    }
  ]
}

module "rds" {
  source = "./rds"
  vpc = module.vpc.vpc_id
  name = var.name
  password = local.db_creds.password
  username = local.db_creds.username
  db_name = local.db_creds.name
}

module "security-group" {
  name = "${var.name}-sg"
  vpc_id = module.vpc.vpc_id
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.1"
}

module "deploy" {
  name = var.name
  source = "./deploy"
  image = "panasyg/taskcafe:v29"

  db_host = module.rds.address
  db_name = local.db_creds.name
  db_pass = local.db_creds.password
  db_user = local.db_creds.username

  wait_for_write = module.eks.cluster_arn
}