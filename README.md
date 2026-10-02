# AWS DevOps Infrastructure Project with Terraform

## 📌 Project Overview

This project demonstrates how to provision and manage AWS infrastructure using Terraform following a production-style architecture.

The infrastructure is designed to keep the application server in a private subnet while exposing the application to users through an Application Load Balancer (ALB).

The project also demonstrates how a Dockerized Java Spring Boot application can run on a private EC2 instance and receive traffic through the ALB.

---

## 🏗️ Architecture

```text
                         Internet
                            |
                            v
                    +----------------+
                    |  Application   |
                    | Load Balancer  |
                    |     Port 80    |
                    +-------+--------+
                            |
                            | Port 8080
                            v
              +---------------------------+
              |       Private Subnet      |
              |                           |
              |      EC2 Instance         |
              |       Port 8080           |
              |           |               |
              |           v               |
              |    Docker Container       |
              |       Port 8080           |
              |           |               |
              |           v               |
              |   Spring Boot Application |
              +---------------------------+
                            |
                            |
                    +-------v--------+
                    |  NAT Gateway   |
                    +-------+--------+
                            |
                    Internet Gateway
☁️ AWS Services Used
Amazon VPC
Public and Private Subnets
Internet Gateway
NAT Gateway
Elastic IP
Route Tables
Application Load Balancer
Target Group
EC2
IAM Role and Instance Profile
AWS Systems Manager (SSM)
Security Groups
🛠️ Technologies Used
Terraform
AWS
Docker
Java
Spring Boot
Git
GitHub
Linux
🔐 Network and Security Design
The EC2 instance is deployed inside a private subnet and does not receive a public IP address.
The Application Load Balancer is deployed in public subnets and acts as the public entry point.
Traffic flow:
Internet
   |
   v
ALB :80
   |
   v
EC2 :8080
   |
   v
Docker :8080
   |
   v
Spring Boot :8080
The EC2 security group allows application traffic only from the ALB security group.
This prevents direct internet access to the EC2 instance.

🌐 VPC Design
The VPC contains:
2 Public Subnets
2 Private Subnets
Internet Gateway
NAT Gateway
Public Route Table
Private Route Table
Public Subnets
Used for internet-facing resources such as the Application Load Balancer.
Private Subnets
Used for application workloads such as the EC2 instance.
NAT Gateway
Allows resources in the private subnet to initiate outbound internet connections when required without making the private EC2 instance publicly accessible.
🚀 Terraform Workflow
Terraform is used to manage the complete AWS infrastructure.
Basic workflow:
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
To remove the infrastructure after testing:
terraform destroy
📁 Terraform Project Structure
aws-devops-project/
│
├── README.md
├── .gitignore
│
├── provider.tf
├── variables.tf
├── vpc.tf
├── subnets.tf
├── internet_gateway.tf
├── nat_gateway.tf
├── route_tables.tf
├── security_groups.tf
├── key_pair.tf
├── iam.tf
├── ec2.tf
├── alb.tf
├── target_group.tf
├── target_attachment.tf
├── alb_listener.tf
└── outputs.tf
🐳 Application Deployment
The application is a Java Spring Boot application packaged as a Docker image.
The Spring Boot application listens on:
8080
The Docker container also uses:
8080
The EC2 instance exposes:
8080
The ALB forwards traffic to the EC2 target on:
8080
❤️ ALB Health Check
The Application Load Balancer uses a target group to monitor the health of the EC2 application.
The target group checks:
Protocol: HTTP
Port: 8080
If the application is not listening on port 8080, the target becomes unhealthy.
🔧 Troubleshooting Experience
During the project, an ALB target initially reported failed health checks.
The issue was investigated by checking:
Target group health
EC2 application port
Docker port mapping
Application availability
Security group rules
The final application architecture uses port 8080 consistently:
ALB :80
   ↓
EC2 :8080
   ↓
Docker :8080
   ↓
Spring Boot :8080
This demonstrates practical troubleshooting of AWS load balancer health checks and application networking.
💰 Cost Management
AWS resources such as NAT Gateway, ALB, EC2 and Elastic IP can generate charges.
For learning environments, infrastructure should be destroyed after testing when it is no longer required:
terraform destroy
The project follows a:
Create → Deploy → Test → Verify → Destroy
workflow to minimize unnecessary AWS costs.
🎯 Key Learning Outcomes
Through this project, I gained practical experience with:
Infrastructure as Code using Terraform
AWS VPC architecture
Public vs private subnet design
Route tables and routing
Internet Gateway
NAT Gateway
Application Load Balancer
Target Groups and health checks
EC2 deployment
IAM roles
AWS Systems Manager
Security Groups
Docker application deployment
Terraform troubleshooting
AWS resource lifecycle management
Git and GitHub
🔄 Future Improvements
Possible improvements include:
Terraform remote state using Amazon S3
State locking
CI validation using GitHub Actions
Automated Terraform plan
Infrastructure monitoring
Auto Scaling
HTTPS using ACM
CloudWatch monitoring
Secrets management using AWS Secrets Manager or Parameter Store
👩‍💻 Project Summary
This project demonstrates the provisioning of a secure AWS application infrastructure using Terraform, with an internet-facing Application Load Balancer routing traffic to a Dockerized Spring Boot application running on a private EC2 instance.
The project focuses on Infrastructure as Code, AWS networking, security, application deployment, troubleshooting, and resource lifecycle management.
