output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.grocerymate_ec2.public_ip
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.postgres_db.address
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.avatars.bucket
}

output "iam_role_name" {
  description = "IAM Role name for EC2"
  value       = aws_iam_role.ec2_role.name
}
