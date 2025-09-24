# 🔷🔹Terraform Infrastructure for AWS Grocery App

This repository contains the Infrastructure as Code (IaC) for GroceryMate, a modern e-commerce application for online grocery shopping. The project is developed as part of the Cloud Track program at Masterschool's Software Engineering Bootcamp, originally created by our mentor and tutor Alejandro Roman Ibanez.

This project provisions a **production-ready AWS infrastructure** for the GroceryMate application using **Terraform**.  
The setup follows best practices with separate networking layers, compute, database, and load balancing.

## Project Diagrams

![AWS infrastructure](https://github.com/YaroslavK1990/AWS_grocery/blob/version2/infrastructure/image/AWS%20infrastructure.png?raw=true)

## 📂 Project Structure

```
infrastructure/
│── image
│── .terraform.lock.hcl
│── README.md
│── asg.tf.disabled
│── iam_role.tf
│── main.tf
│── outputs.tf
│── s3.tf
│── sg.tf
│── variables.tf
│── vpc.tf
```

## 📦 Terraform Infrastructure

### 1. **VPC**

- Provisions the **Virtual Private Cloud**.
- Creates **Public** and **Private Subnets**.
- Configures **Route Tables** and **Internet Gateway**.
- **Outputs**:
  - VPC ID
  - Public Subnet IDs
  - Private Subnet IDs

### 2. **Security Groups**

- Defines **Security Groups** for:
  - **ALB** – allows inbound HTTP/HTTPS (80, 443).
  - **EC2** – allows inbound SSH from a specific IP and inbound traffic from ALB on port 5000.
  - **RDS** – allows inbound traffic only from EC2 instances.
- **Outputs**:
  - ALB SG ID
  - EC2 SG ID
  - RDS SG ID

### 3. **Application Load Balancer (ALB)**

- Deploys an **Application Load Balancer**.
- Configures a **Target Group** for EC2 instances.
- **Listeners**:
  - Port 80 (HTTP)
  - Port 443 (HTTPS)
- **Health Checks** on `/health`.

### 4. **EC2**

- Defines EC2 configuration:
  - **AMI**: Custom preconfigured with Docker & Docker Compose.
  - **Instance Type**: `t2.micro`.
  - **IAM Instance Profile**.
  - **Security Group**.
  - **EBS Volume**: 20 GB (`gp3`).

### 5. **Auto Scaling Group (ASG)**

- Deploys EC2 instances across **Public Subnets**.
- Uses the Launch Template for configuration.
- **Scaling Settings**:
  - Minimum: 1
  - Desired: 3
  - Maximum: 4
- Attaches EC2 instances to the ALB Target Group.

### 6. **IAM Role**

- Creates an **IAM Role** for EC2 instances.
- Policies:
  - **ECR Read Access** (to pull Docker images).
  - **S3 Full Access** (for avatar storage).
  - **CloudWatch Logs** (for monitoring).
- **Outputs**:
  - IAM Role name
  - Instance Profile name

### 8. **RDS (PostgreSQL)**

- Provisions an **Amazon RDS PostgreSQL** instance.
- **Configuration**:
  - Instance Type: `db.t3.micro`.
  - Multi-AZ enabled.
  - Allocated Storage: 20 GB (`gp2`).
- **Security**:
  - Deployed in **Private Subnets**.
  - Accessible only from EC2 Security Group.
- **Backups**: Restores database from a snapshot.
- **Outputs**:
  - RDS Endpoint

### 9. **S3 Bucket**

- Creates an **S3 Bucket** for storing user avatars.
- **Configuration**:
  - Public folder: `/avatars/`.
  - CORS policy for frontend access.
  - `user_default.png` uploaded by default.
- **Permissions**:
  - EC2 instances have full access via IAM Role.

## ✅ Summary

This setup includes:

- **Networking (VPC + Subnets + IGW)**
- **Security (Security Groups + IAM Roles)**
- **Compute (EC2 + ASG)**
- **Load Balancing (ALB)**
- **Database (RDS PostgreSQL)**
- **Storage (S3)**

All resources are provided separately in each file, making the infrastructure **scalable, reusable, and easy to maintain**.

---

## GroceryMate – Deployment & Installation Guide

---

This guide explains how to set up and deploy the **GroceryMate** application on AWS using Terraform, PostgreSQL, and Docker.

## Prerequisites

Before starting, ensure you have the following installed:

- **Python 3.11+** – Backend runtime
- **PostgreSQL** – Database
- **Terraform** – Infrastructure as Code
- **AWS CLI** – Manage AWS resources from your terminal

## Clone the Repository

```bash
git clone https://github.com/AlejandroRomanIbanez/AWS_grocery.git

cd AWS_grocery
```

## AWS CLI Setup

Install AWS CLI

```bash
brew install awscli
```

Verify installation:

```bash
aws --version
```

## Configure SSO Authentication

```bash
aws configure sso
```

For more details: [AWS CLI SSO Configuration Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html)

## Login via SSO

```bash
aws sso login
```

Verify your identity:

```bash
aws sts get-caller-identity
```

⚠️ Since SSO credentials are temporary, you might need to re-authenticate with aws sso login periodically.

## Deploy Infrastructure with Terraform

```bash
cd infrastructure

terraform init
terraform plan
terraform apply
terraform destroy
```

## Connect to EC2 Instance

```bash
ssh -i /path/to/your-key.pem ec2-user@<EC2_PUBLIC_IP>
```

## System Update & Essential Packages

Update system and install dependencies:

```bash
sudo yum update -y
sudo yum install -y git python3 python3-pip postgresql15 postgresql15-server postgresql15-contrib
```

Verify installations:

```bash
git --version
python3 --version
pip --version
psql --version
```

## PostgreSQL Configuration

Create database and user:

```bash
psql -U postgres -c "CREATE DATABASE grocerymate_db;"
psql -U postgres -c "CREATE USER grocery_user WITH ENCRYPTED PASSWORD '<your_secure_password>';"
psql -U postgres -c "ALTER USER grocery_user WITH SUPERUSER;"
```

Check tables:

```bash
psql -U grocery_user -d grocerymate_db -c "SELECT * FROM users;"
psql -U grocery_user -d grocerymate_db -c "SELECT * FROM products;"
```

## Python Environment Setup

Install dependencies:

```bash
cd backend
pip install -r requirements.txt
```

## Environment Variables

Generate a secure JWT key:

```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

Create `.env` file:

```bash
touch .env
```

Fill in required variables:

```bash
echo "JWT_SECRET_KEY=<your_generated_key>" >> .env
echo "POSTGRES_USER=grocery_user" >> .env
echo "POSTGRES_PASSWORD=<your_secure_password>" >> .env
echo "POSTGRES_DB=grocerymate_db" >> .env
echo "POSTGRES_HOST=localhost" >> .env
echo "POSTGRES_URI=postgresql://grocery_user:<your_secure_password>@localhost:5432/grocerymate_db" >> .env
```

## Run Application with Docker

Start the application (replace placeholders):

```bash
docker run --network host \
  -e S3_BUCKET_NAME=<bucket_name> \
  -e S3_REGION=<region_name> \
  -e USE_S3_STORAGE=true \
  -e POSTGRES_USER=grocery_user \
  -e POSTGRES_PASSWORD=<your_secure_password> \
  -e POSTGRES_DB=grocerymate_db \
  -e POSTGRES_HOST=<rds-endpoint> \
  -e POSTGRES_URI=postgresql://<psql_user>:<psql_password>@<rds-endpoint>:5432/<psql_db> \
  -e JWT_SECRET_KEY=<your_secret_key> \
  -e SECRET_KEY=<your_secret_key> \
  -p 5000:5000 grocerymate
```

## Access the Application

Open in your browser:

```bash
http://<EC2_PUBLIC_IP>:5000
```

✅ Congratulations! Your GroceryMate application is now deployed and running.
