# Загальні
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

# EC2
variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key name for EC2"
  type        = string
}

variable "ssh_allowed_ip" {
  description = "IP address allowed for SSH access"
  type        = string
}

# IAM
variable "ec2_instance_profile" {
  description = "IAM instance profile name for EC2"
  type        = string
  default     = "ec2-instance-profile"
}

# RDS
variable "db_allocated_storage" {
  description = "The allocated storage in GB for the RDS instance"
  type        = number
  default     = 20
}

variable "db_engine" {
  description = "The database engine to use"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "The engine version to use"
  type        = string
  default     = "15"
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "grocerydb"
}

variable "db_username" {
  description = "Master DB username"
  type        = string
  default     = "adminuser"
}

variable "db_password" {
  description = "Master DB password"
  type        = string
  sensitive   = true
}

# ALB
variable "alb_name" {
  description = "Application Load Balancer name"
  type        = string
  default     = "grocery-alb"
}

variable "target_group_name" {
  description = "Target group name for ALB"
  type        = string
  default     = "grocery-tg"
}

variable "target_group_port" {
  description = "Port for target group"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Number of consecutive successes before healthy"
  type        = number
  default     = 3
}

variable "unhealthy_threshold" {
  description = "Number of consecutive failures before unhealthy"
  type        = number
  default     = 3
}

# S3
variable "s3_bucket_name" {
  description = "S3 bucket name for avatars"
  type        = string
}

