resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [
      aws_subnet.private-us-east-1a.id,
      aws_subnet.private-us-east-1b.id,
      aws_subnet.public-us-east-1a.id,
      aws_subnet.public-us-east-1b.id
    ]

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public-us-east-1a" {
  vpc_id     = var.vpc
  cidr_block = "10.0.101.0/24"

  tags = {
    Name = "main"
  }
}


resource "aws_subnet" "public-us-east-1b" {
  vpc_id     = var.vpc
  cidr_block = "10.0.102.0/24"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "private-us-east-1a" {
  vpc_id     = var.vpc
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "main"
  }
}


resource "aws_subnet" "private-us-east-1b" {
  vpc_id     = var.vpc
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "main"
  }
}

resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-sg"
  vpc_id      = var.vpc

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "default" {
  identifier           = "${var.name}-psql"
  engine               = "postgres"
  engine_version       = "14"
  instance_class       = "db.t4g.large"
  name              = var.db_name
  username             = var.username
  password             = var.password
  allocated_storage    = 20
  storage_type         = "gp2"
  publicly_accessible  = false
  backup_retention_period = 7
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}
