provider "aws" {
  region = "eu-central-1"
}

# Default VPC (ensure it exists)
resource "aws_default_vpc" "default" {
  tags = {
    Name = "default-vpc"
  }
}

# Get the Default VPC explicitly
data "aws_vpc" "default" {
  default = true
}

# Get subnets from default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow inbound traffic for SSH and HTTP"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["94.222.133.149/32"]
    description = "Allow SSH inbound traffic"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP inbound traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow inbound traffic from EC2 for database access"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
    description     = "Allow PostgreSQL access from EC2 instance"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = "ami-015cbce10f839bd0c"
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnets.default.ids[0]
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "FreeTierInstance"
  }

  depends_on = [aws_security_group.ec2_sg]
}

# Subnet Group for RDS
resource "aws_db_subnet_group" "default" {
  name       = "default-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "Default subnet group"
  }
}

# PostgreSQL 15
resource "aws_db_parameter_group" "postgres_custom_group" {
  name   = "my-postgres-param-group"
  family = "postgres15"
}

# RDS Instance
resource "aws_db_instance" "postgres_db" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "15.8"
  instance_class         = "db.t3.micro"
  db_name                = "mydatabase"
  username               = "adminuser"
  password               = var.db_password
  parameter_group_name   = aws_db_parameter_group.postgres_custom_group.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  tags = {
    Name = "MyPostgresDB"
  }
}
