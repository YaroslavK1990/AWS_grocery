# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "grocery-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Policy for EC2 to access S3
resource "aws_iam_policy" "s3_access_policy" {
  name        = "grocery-s3-access"
  description = "Allow EC2 to access grocerymate avatars S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.avatars.arn,
          "${aws_s3_bucket.avatars.arn}/*"
        ]
      }
    ]
  })
}

# Attach EC2-S3-Access-Policy
resource "aws_iam_role_policy_attachment" "s3_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

# IAM Instance Profile (Required for EC2 to Use the Role)
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "grocery-ec2-profile"
  role = aws_iam_role.ec2_role.name
}
