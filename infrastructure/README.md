# Terraform Infrastructure for AWS Grocery App

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

---

### 1. **VPC**

- Provisions the **Virtual Private Cloud**.
- Creates **Public** and **Private Subnets**.
- Configures **Route Tables** and **Internet Gateway**.
- **Outputs**:
  - VPC ID
  - Public Subnet IDs
  - Private Subnet IDs

---

### 2. **Security Groups**

- Defines **Security Groups** for:
  - **ALB** – allows inbound HTTP/HTTPS (80, 443).
  - **EC2** – allows inbound SSH from a specific IP and inbound traffic from ALB on port 5000.
  - **RDS** – allows inbound traffic only from EC2 instances.
- **Outputs**:
  - ALB SG ID
  - EC2 SG ID
  - RDS SG ID

---

### 3. **Application Load Balancer (ALB)**

- Deploys an **Application Load Balancer**.
- Configures a **Target Group** for EC2 instances.
- **Listeners**:
  - Port 80 (HTTP)
  - Port 443 (HTTPS)
- **Health Checks** on `/health`.

---

### 4. **EC2 Launch Template**

- Defines EC2 configuration:
  - **AMI**: Custom preconfigured with Docker & Docker Compose.
  - **Instance Type**: `t2.micro`.
  - **IAM Instance Profile**.
  - **Security Group**.
  - **EBS Volume**: 20 GB (`gp3`).

---

### 5. **Auto Scaling Group (ASG)**

- Deploys EC2 instances across **Public Subnets**.
- Uses the Launch Template for configuration.
- **Scaling Settings**:
  - Minimum: 1
  - Desired: 3
  - Maximum: 4
- Attaches EC2 instances to the ALB Target Group.

---

### 6. **IAM Role**

- Creates an **IAM Role** for EC2 instances.
- Policies:
  - **ECR Read Access** (to pull Docker images).
  - **S3 Full Access** (for avatar storage).
  - **CloudWatch Logs** (for monitoring).
- **Outputs**:
  - IAM Role name
  - Instance Profile name

---

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

---

### 9. **S3 Bucket**

- Creates an **S3 Bucket** for storing user avatars.
- **Configuration**:
  - Public folder: `/avatars/`.
  - CORS policy for frontend access.
  - `user_default.png` uploaded by default.
- **Permissions**:
  - EC2 instances have full access via IAM Role.

---

## ✅ Summary

This setup includes:

- **Networking (VPC + Subnets + IGW)**
- **Security (Security Groups + IAM Roles)**
- **Compute (EC2 + ASG + Launch Template)**
- **Load Balancing (ALB)**
- **Database (RDS PostgreSQL)**
- **Storage (S3)**
- **Monitoring (CloudWatch)**

All resources are provided separately in each file, making the infrastructure **scalable, reusable, and easy to maintain**.
