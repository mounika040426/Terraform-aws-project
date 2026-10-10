# AWS Terraform Infrastructure Project

## 📌 Project Overview

This project demonstrates how to provision and manage AWS infrastructure
using Terraform. It was built as a hands-on Infrastructure as Code (IaC)
project, with an emphasis on reusable configuration, network design,
secure application hosting, load balancing, and Terraform state
management.

The infrastructure was deployed in the **Asia Pacific (Mumbai) region
(`ap-south-1`)**. It includes a custom VPC, public and private subnets
across two Availability Zones, internet and NAT gateways, route tables,
security groups, an Application Load Balancer (ALB), and EC2-based
application hosting.

The project also included a remote Terraform state backend using Amazon
S3 and a DynamoDB table for state locking. The backend was tested and
then deliberately cleaned up to avoid ongoing AWS charges. The README
documents that lifecycle and does not assume the state bucket or locking
table still exists.

> **Cost reminder:** AWS resources such as NAT Gateways, public IPv4
> addresses, load balancers, and some storage/network services can incur
> charges. Recreate only the resources you need, monitor Billing, and
> clean up when finished.

------------------------------------------------------------------------

## 🏗️ Architecture

``` text
                         Developer
                             |
                             v
                    +------------------+
                    | Git / GitHub     |
                    | Terraform Code   |
                    +--------+---------+
                             |
                             v
                    +------------------+
                    | Terraform CLI    |
                    | init / validate  |
                    | plan / apply     |
                    +--------+---------+
                             |
                             v
                 +---------------------------+
                 | AWS VPC (ap-south-1)      |
                 |                           |
                 |  Public Subnets (2 AZs)   |
                 |  +---------------------+  |
Internet ------->|  | Internet Gateway    |  |
                 |  +----------+----------+  |
                 |             |             |
                 |  +----------v----------+  |
                 |  | Application Load    |  |
                 |  | Balancer (ALB)      |  |
                 |  +----------+----------+  |
                 |             |             |
                 |  Private Subnets (2 AZs)  |
                 |  +----------v----------+  |
                 |  | EC2 Application     |  |
                 |  | Instance(s)         |  |
                 |  | Docker / Java App   |  |
                 |  +---------------------+  |
                 |             |             |
                 |  Private outbound access  |
                 |  through NAT Gateway      |
                 +---------------------------+

 Terraform state backend (configured and tested, then deleted):
       Terraform CLI ---> Amazon S3 state bucket
                    \--> DynamoDB lock table
```

*This is a high-level view of the project design. The exact resource
names, subnet CIDRs, Availability Zones, and instance counts are defined
in the Terraform configuration.*

------------------------------------------------------------------------

## ☁️ Technologies and AWS Services

-   **Terraform** --- Infrastructure as Code; provisions and updates AWS
    resources.
-   **AWS VPC** --- isolated network for project resources.
-   **Public and private subnets** --- separate internet-facing and
    application tiers.
-   **Internet Gateway (IGW)** --- provides internet routing for public
    subnets.
-   **NAT Gateway and Elastic IP** --- allows private-subnet resources
    to initiate outbound internet connections without assigning them
    public IP addresses.
-   **Route tables** --- define public and private network routes.
-   **Application Load Balancer (ALB)** --- distributes incoming HTTP
    requests to registered targets.
-   **EC2** --- hosts the application in a private subnet.
-   **Security Groups** --- control allowed inbound and outbound
    traffic.
-   **IAM instance profile / Systems Manager (SSM)** --- supports
    AWS-managed instance access where configured.
-   **Amazon S3** --- used for remote Terraform state during the backend
    exercise; bucket later deleted.
-   **Amazon DynamoDB** --- used for Terraform state locking during the
    backend exercise; table later deleted.
-   **Docker** --- packages/runs the Java application on the EC2 host.
-   **Linux, AWS CLI, and Git** --- command-line administration and
    source control.

------------------------------------------------------------------------

## 🧱 Infrastructure Components

### VPC and networking

The Terraform configuration provisions a VPC with:

-   Two public subnets.
-   Two private subnets.
-   An Internet Gateway.
-   A NAT Gateway and Elastic IP for private-subnet outbound access.
-   Public and private route tables and their associations.

Public subnets are intended for internet-facing components such as the
ALB. Application EC2 instances are placed in private subnets without
public IP addresses.

### Application Load Balancer

The ALB accepts application traffic and forwards it to a target group.
The target group health check is used to determine whether the
application target is healthy.

During testing, the Java application was confirmed reachable through the
ALB after the target became healthy. The application was configured to
listen on **port `8080`**; the ALB target group and relevant
security-group rules must use the same application port.

### EC2 and application

The EC2 instance is deployed in a private subnet. The bootstrap
configuration installs Docker and prepares the host to run the
application container. An IAM instance profile was also configured for
the intended SSM-based management path.

The exact AMI ID, instance type, key-pair name, image tag, and bootstrap
commands are set in the Terraform files and may need updating as AWS
images and project configuration change.

------------------------------------------------------------------------

## 🔄 Terraform Workflow

The typical workflow used for this project is:

1.  **Initialize** --- download provider plugins and initialize the
    configured backend.
2.  **Format** --- standardize Terraform file formatting.
3.  **Validate** --- check configuration syntax and internal
    consistency.
4.  **Plan** --- preview the changes Terraform intends to make.
5.  **Apply** --- create or update the AWS infrastructure after
    reviewing the plan.
6.  **Verify** --- inspect AWS resources, target health, and application
    access through the ALB.
7.  **Destroy / cleanup** --- remove resources when the lab is no longer
    needed.

Useful commands:

``` bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply
terraform state list
terraform output
```

Review the plan before applying changes. `terraform apply` can create
billable AWS resources.

### Terraform state

Terraform state records the relationship between the configuration and
the real infrastructure. It is important for planning and safely
managing subsequent changes.

For this project, an S3 remote backend and DynamoDB state-locking table
were configured and tested. The state objects were inspected during
cleanup, including versioned objects, and then the S3 bucket and
DynamoDB table were deleted to avoid ongoing costs.

**Current backend status:** the remote S3 bucket and DynamoDB table are
no longer available. If the Terraform backend configuration still
references those resources, `terraform init` and state operations will
fail until the backend is recreated or the configuration is deliberately
changed to use another backend.

Do not delete a remote state bucket while it is still the active backend
for infrastructure you need to manage. First ensure the infrastructure
is destroyed or that the state has been safely migrated/backed up. For a
portfolio repository, document the backend setup and cleanup, but never
commit credentials or sensitive state files.

------------------------------------------------------------------------

## 🔐 Security Considerations

-   Keep AWS access keys and secrets out of Terraform files, Git
    history, and the README.
-   Prefer an appropriately scoped IAM identity rather than routine use
    of the AWS root account.
-   Keep EC2 instances in private subnets where possible.
-   Allow application traffic only from the intended source, such as the
    ALB security group.
-   Use Systems Manager Session Manager where configured instead of
    opening SSH to the internet.
-   Review security-group rules, IAM permissions, and public exposure
    before applying changes.
-   Treat Terraform state as sensitive because it can contain
    infrastructure details and, depending on resources, secret values.
-   Do not commit private keys, `terraform.tfstate`,
    `terraform.tfstate.backup`, `.terraform/`, or secret `.tfvars`
    files.

Example `.gitignore` entries:

``` gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
crash.log
*.tfvars
!example.tfvars
```

Only keep `example.tfvars` if it contains safe placeholder values and no
secrets.

------------------------------------------------------------------------

## 🧪 Validation and Verification

The configuration was validated and the infrastructure was applied and
tested. The application was reachable through the ALB after the target
group reported healthy.

Useful commands:

``` bash
# Terraform configuration checks
terraform fmt -check -recursive
terraform validate
terraform plan

# Inspect Terraform-managed resources
terraform state list
terraform output

# Check AWS identity and region
aws sts get-caller-identity
aws configure get region

# Inspect EC2 instances
aws ec2 describe-instances \
  --region ap-south-1 \
  --query 'Reservations[].Instances[].{ID:InstanceId,State:State.Name,Subnet:SubnetId,PublicIP:PublicIpAddress}' \
  --output table

# Inspect load balancers
aws elbv2 describe-load-balancers --region ap-south-1

# Inspect target groups
aws elbv2 describe-target-groups --region ap-south-1
```

The AWS CLI commands query the live account. If the infrastructure has
already been destroyed, empty results are expected. The exact Terraform
outputs and resource names depend on the files in the repository.

------------------------------------------------------------------------

## 🩺 Troubleshooting

### `terraform init` fails for the S3 backend

The project's S3 state bucket and DynamoDB locking table were deleted
after the backend test. If the backend block still points to the deleted
bucket, recreate the backend resources or intentionally migrate to a
different backend before running Terraform operations.

Do not casually remove or edit the backend block when state exists.
Follow Terraform's backend migration workflow and preserve the state
first.

### ALB target is unhealthy

Check:

-   The application process/container is running.
-   The application listens on port `8080`.
-   The target group uses the correct target port and health-check path.
-   The EC2 security group permits the target port from the ALB security
    group.
-   The health-check response code and application path match the target
    group configuration.
-   EC2 logs and Docker/container logs show no startup errors.

### Application is not reachable through the ALB

Check the ALB listener, target-group registration and health, subnet
routing, and security-group rules. Confirm that the ALB is
internet-facing only if that is the intended design, and that the EC2
instance remains private.

### Unexpected AWS charges

Check the AWS Billing and Cost Management dashboard and review running
resources in the `ap-south-1` region. Pay particular attention to NAT
Gateways, load balancers, Elastic IP/public IPv4 usage, and storage.
Deleting only the Terraform state bucket does **not** remove other AWS
infrastructure.

------------------------------------------------------------------------

## 💰 Cost Management and Cleanup

This project was built as a learning lab. Some networking resources can
incur charges even when the application receives little or no traffic.

Before finishing a lab:

1.  Review the Terraform plan and identify resources that will be
    removed.
2.  If the infrastructure is no longer needed, destroy it through
    Terraform while the correct state is available.
3.  Confirm in the AWS Console or CLI that billable resources have been
    removed.
4.  Check for remaining NAT Gateways, load balancers, Elastic IPs, EC2
    instances, EBS volumes, snapshots, and other resources.
5.  Remove the S3 backend bucket and DynamoDB lock table only after
    state is no longer needed and any required state backup or migration
    is complete.
6.  Check Billing and Cost Explorer afterward; billing data can take
    time to update.

Typical cleanup command, **only when you intend to delete all resources
managed by the current Terraform state**:

``` bash
terraform destroy
```

The remote state bucket and DynamoDB table used for this exercise were
subsequently deleted, including the bucket's versioned state objects, to
reduce ongoing costs. As a result, the original remote backend is not
currently available. Recreate it only if you need to run the project
again with remote state.

------------------------------------------------------------------------

## 📁 Suggested Project Structure

The exact file names should match the repository. A typical layout may
look like this:

``` text
aws-devops-project/
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── versions.tf
├── backend.tf
├── terraform.tfvars.example
└── .gitignore
```

If the repository uses separate files for VPC, subnets, routing,
security groups, ALB, EC2, or IAM resources, list those actual files
here instead. Do not commit generated state files, credentials, or
private keys.

------------------------------------------------------------------------

## 🎯 Key Learning Outcomes

Through this project, I gained practical experience with:

-   Defining AWS infrastructure as code with Terraform.
-   Designing a VPC with public and private subnet tiers.
-   Configuring Internet Gateway, NAT Gateway, Elastic IP, and route
    tables.
-   Deploying private EC2 application hosting behind an Application Load
    Balancer.
-   Configuring target groups, health checks, and security-group rules.
-   Using IAM instance profiles and the intended SSM management
    approach.
-   Running Terraform format, initialization, validation, plan, apply,
    state, and cleanup workflows.
-   Configuring and testing remote Terraform state with S3.
-   Understanding state locking with DynamoDB and the implications of
    deleting backend resources.
-   Verifying AWS resources and diagnosing ALB/application connectivity
    issues.
-   Considering AWS cost control and infrastructure cleanup.

------------------------------------------------------------------------

## 🔄 Future Improvements

Possible improvements include:

-   Recreate a low-cost remote backend only when needed, with a clear
    lifecycle and cleanup procedure.
-   Add S3 bucket versioning, encryption, and restrictive bucket
    policies while the backend is in use.
-   Use a supported Terraform state-locking approach for the selected
    Terraform version and backend configuration.
-   Add reusable Terraform modules for networking, security, ALB, and
    compute.
-   Use least-privilege IAM roles and Systems Manager Session Manager.
-   Add automated Terraform formatting, validation, and plan checks in a
    CI pipeline.
-   Add HTTPS using ACM and a suitable DNS configuration.
-   Add stronger monitoring, alarms, and centralized logs.
-   Document estimated costs and verify resource cleanup after each lab.
-   Use separate environments and variables for development and
    production.

------------------------------------------------------------------------

## 👩‍💻 Project Summary

The `aws-devops-project` demonstrates provisioning AWS infrastructure
with Terraform, including a multi-subnet VPC, public and private
routing, NAT-based outbound access, private EC2 application hosting, and
an Application Load Balancer. The Java application was tested through
the ALB after its target became healthy.

The project also covered remote Terraform state using S3 and state
locking with DynamoDB. Those backend resources were tested and later
deleted as a cost-control decision. This repository documents both the
implementation and the cleanup trade-off so that the infrastructure can
be understood and recreated responsibly.
