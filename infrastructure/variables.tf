variable "key_name" {
  description = "SSH-key EC2"
  type        = string
}


variable "db_password" {
  description = "Password for RDS PostgreSQL"
  type        = string
  sensitive   = true
}
