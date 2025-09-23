# Description: Main Terraform configuration file for GroceryMate infrastructure.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# EC2 INSTANCE
resource "aws_instance" "grocerymate_ec2" {
  ami                    = var.ami_id
  instance_type          = var.ec2_instance_type
  subnet_id              = aws_subnet.private_a.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = var.ec2_instance_profile

  tags = {
    Name = "grocerymate-ec2"
  }

  depends_on = [aws_security_group.ec2_sg]
}

# LOAD BALANCER
resource "aws_lb" "grocery_alb" {
  name               = "grocery-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.grocery_alb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = { Name = "grocery-alb" }
}

resource "aws_lb_target_group" "grocery_tg" {
  name     = "grocery-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = var.health_check_path
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = { Name = "grocery-target-group" }
}

resource "aws_lb_target_group_attachment" "ec2_attach" {
  target_group_arn = aws_lb_target_group.grocery_tg.arn
  target_id        = aws_instance.grocerymate_ec2.id
  port             = 80
}

resource "aws_lb_listener" "grocery_http" {
  load_balancer_arn = aws_lb.grocery_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grocery_tg.arn
  }
}

# RDS
resource "aws_db_subnet_group" "default" {
  name       = "grocery-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = { Name = "DB subnet group" }
}

resource "aws_db_parameter_group" "postgres_custom_group" {
  name   = "my-postgres-param-group"
  family = "postgres15"
}

resource "aws_db_instance" "postgres_db" {
  allocated_storage      = var.db_allocated_storage
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = aws_db_parameter_group.postgres_custom_group.name
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  tags = { Name = "MyPostgresDB" }
}
