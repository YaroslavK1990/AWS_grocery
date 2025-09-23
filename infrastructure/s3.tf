# S3 Bucket for storing avatars
resource "aws_s3_bucket" "avatars" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = {
    Name        = "grocerymate-avatars"
    Environment = "Dev"
  }
}

# Public access prohibited
resource "aws_s3_bucket_public_access_block" "avatars" {
  bucket = aws_s3_bucket.avatars.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enabling versioning
resource "aws_s3_bucket_versioning" "avatars" {
  bucket = aws_s3_bucket.avatars.id

  versioning_configuration {
    status = "Enabled"
  }
}
