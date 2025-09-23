# Terraform Infrastructure for AWS Grocery App

This repository contains the Infrastructure as Code (IaC) for GroceryMate, a modern e-commerce application for online grocery shopping. The project is developed as part of the Cloud Track program at Masterschool's Software Engineering Bootcamp, originally created by our mentor and tutor Alejandro Roman Ibanez.

This project provisions a **production-ready AWS infrastructure** for the GroceryMate application using **Terraform**.  
The setup follows best practices with separate networking layers, compute, database, and load balancing.

## Project Diagrams

![AWS infrastructure]https://github.com/YaroslavK1990/AWS_grocery/blob/version2/infrastructure/image/AWS%20infrastructure.png?raw=true

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
