# Capgemini Invent DevOps Demo 

A complete end-to-end DevOps demo project that deploys a static frontend website to AWS EC2 using Terraform and GitHub Actions.

## Project Summary

This project demonstrates a beginner-friendly but realistic DevOps workflow with:
- A static website built with HTML, CSS, and JavaScript
- AWS infrastructure provisioned using Terraform
- An Ubuntu EC2 instance running Nginx to serve the site
- GitHub Actions CI workflow for Terraform formatting, validation, and security scanning
- GitHub Actions CD workflow using AWS OIDC for Terraform apply
- A manual destroy workflow for safe AWS cleanup
- Local Terraform state only, suitable for a demo

## Project Structure

```
.
├── .gitignore
├── README.md
├── .github
│   └── workflows
│       ├── ci.yml
│       ├── cd.yml
│       └── destroy.yml
├── terraform
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── userdata.sh
│   └── terraform.tfvars
└── website
    ├── index.html
    ├── style.css
    └── app.js
```

## What Files Do

- `terraform/main.tf`: Creates VPC, public subnet, internet gateway, route table, security group, and EC2 instance.
- `terraform/provider.tf`: Configures the AWS provider and default tags.
- `terraform/variables.tf`: Declares input variables for AWS region, environment, instance type, SSH CIDR, and more.
- `terraform/outputs.tf`: Exposes outputs including public IP, website URL, instance ID, VPC ID, and SSH command.
- `terraform/userdata.sh`: EC2 bootstrap script that installs Nginx and writes the static site into `/var/www/html`.
- `terraform/terraform.tfvars`: Example values for local deployment.
- `website/index.html`: Static HTML landing page for the demo website.
- `website/style.css`: Responsive CSS styling for the frontend.
- `website/app.js`: Lightweight JavaScript for timestamp and console metadata.
- `.github/workflows/ci.yml`: Runs on PRs and branch pushes to validate Terraform and run Checkov.
- `.github/workflows/cd.yml`: Runs on `main` merges to apply Terraform using AWS OIDC.
- `.github/workflows/destroy.yml`: Manual `workflow_dispatch` cleanup of Terraform-managed AWS resources.

## Demo Behavior

The website shows:
- `Hello, Welcome to Capgemini Invent`
- `Version: v1.0`
- `Environment: Dev`

It uses a simple responsive layout with a header, hero card, info cards, and footer.

## AWS Infra Details

Terraform provisions:
- `aws_vpc.main` with `10.0.0.0/16`
- `aws_subnet.public` with `10.0.1.0/24` and public IP mapping
- `aws_internet_gateway.igw`
- `aws_route_table.public`
- `aws_security_group.web` allowing HTTP port `80` and SSH port `22`
- `aws_instance.web` using latest Ubuntu 22.04 and EC2 user data for Nginx

### Security notes for this demo

- HTTP port `80` is open for public website access.
- SSH is restricted by `allowed_ssh_cidr` in `terraform/terraform.tfvars`.
- EC2 metadata requires IMDSv2.
- Local Terraform state is used for simplicity.

## AWS Region

The default AWS region is `us-east-1`.

## GitHub Secrets Required

Add these secrets to your GitHub repository:
- `AWS_ROLE_ARN`: IAM OIDC role ARN used by GitHub Actions.
- `EC2_KEY_PAIR_NAME`: EC2 Key Pair name for SSH access.

## Optional GitHub Secrets

- `AWS_REGION`: override the default region if needed.

## Example IAM Configuration

### IAM Trust Policy for GitHub OIDC

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_ORG/YOUR_REPO:*"
        }
      }
    }
  ]
}
```

### Example IAM Permissions

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:RunInstances",
        "ec2:TerminateInstances",
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:AttachVolume",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
```

> Note: This example policy is demo-oriented. For production, tighten permissions and use least privilege.

## Setup and Deployment

### 1. Clone the repository

```bash
git clone <repo-url>
cd CG-demo-project
```

### 2. Configure Terraform variables

Open `terraform/terraform.tfvars` and set:
- `key_pair_name` to your existing EC2 key pair
- `allowed_ssh_cidr` to your own public IP, e.g. `203.0.113.5/32`

### 3. Validate locally

```bash
cd terraform
terraform init
terraform fmt -check -recursive
terraform validate
```

### 4. Push to GitHub

Commit and push your changes.

### 5. Run CI

- `ci.yml` runs on PRs and non-main pushes.
- It checks Terraform formatting, validates config, and runs Checkov.

### 6. Deploy on merge to `main`

- `cd.yml` runs on pushes to `main`.
- It authenticates with AWS OIDC, runs `terraform init`, `terraform plan`, and `terraform apply`.
- After apply, it validates the website endpoint.

## Local Terraform Commands

```bash
cd terraform
terraform init
terraform plan -var="key_pair_name=<your-key-pair-name>"
terraform apply -auto-approve -var="key_pair_name=<your-key-pair-name>"
```

## Destroy / Cleanup

### GitHub workflow cleanup

1. Open GitHub Actions.
2. Run the `Destroy — Terraform Infrastructure Cleanup` workflow.
3. Enter `DESTROY` to confirm.

### Local cleanup command

```bash
cd terraform
terraform destroy -auto-approve -var="key_pair_name=<your-key-pair-name>"
```

## Validation Checklist

- [ ] `terraform fmt -check -recursive` passes
- [ ] `terraform validate` passes
- [ ] CI workflow runs successfully on PR or branch push
- [ ] CD workflow runs successfully on `main`
- [ ] Website is reachable at `http://<EC2_PUBLIC_IP>`
- [ ] Website displays the demo content

## Troubleshooting

- If formatting fails, run:
  ```bash
  terraform fmt -recursive
  ```
- If validation fails, inspect the Terraform error output.
- If the website is not reachable:
  - Confirm the EC2 instance is in the public subnet.
  - Confirm security group allows inbound port `80`.
  - Confirm Nginx started successfully on the instance.
- If OIDC auth fails, verify `AWS_ROLE_ARN` and IAM trust policy.
- If destroy fails, inspect GitHub Actions logs and rerun after fixing state.

## Expected Result

After deployment, the demo site should be available at `http://<EC2_PUBLIC_IP>` and display:
- `Hello, Welcome to Capgemini Invent`
- `Version: v1.0`
- `Environment: Dev`

The project is now documented for a full demo workflow, including AWS provisioning, deployment, validation, and cleanup.
