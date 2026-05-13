# Capgemini Invent DevOps Demo

A minimal end-to-end DevOps demo project that deploys a static frontend website to AWS EC2 using Terraform and GitHub Actions.

## Project Overview

This repository demonstrates a beginner-friendly DevOps workflow with:
- Static website built with HTML, CSS, and JavaScript
- AWS infrastructure deployed with Terraform
- EC2 Ubuntu instance running Nginx
- GitHub Actions CI pipeline for Terraform validation and security scanning
- GitHub Actions CD pipeline using AWS OIDC to apply Terraform
- Manual destroy workflow to clean up AWS resources

## Repository Structure

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

## What Each File Does

- `terraform/main.tf`: Defines AWS VPC, public subnet, internet gateway, route table, security group, and EC2 instance.
- `terraform/provider.tf`: Configures the AWS provider and default tags.
- `terraform/variables.tf`: Declares configurable deployment variables.
- `terraform/outputs.tf`: Exposes EC2 public IP, website URL, instance ID, VPC ID, and SSH command.
- `terraform/userdata.sh`: EC2 user data script that installs Nginx and deploys the static website to `/var/www/html`.
- `terraform/terraform.tfvars`: Example Terraform variable values. Update this before deployment.
- `website/index.html`: Static site markup and content.
- `website/style.css`: Responsive styling for the frontend.
- `website/app.js`: Client-side script that shows deployment metadata in console and page footer.
- `.github/workflows/ci.yml`: Pull request/push CI workflow for formatting, validation, and Checkov security scanning.
- `.github/workflows/cd.yml`: Main branch deployment workflow that applies Terraform using AWS OIDC.
- `.github/workflows/destroy.yml`: Manual cleanup workflow to destroy the Terraform-managed infrastructure.

## Prerequisites

1. AWS account with permissions to create VPC, EC2, IAM, and networking resources.
2. GitHub repository that uses GitHub Actions.
3. Existing EC2 Key Pair in the chosen AWS region.
4. GitHub OIDC-enabled IAM role and `AWS_ROLE_ARN` secret configured in GitHub.
5. GitHub secret `EC2_KEY_PAIR_NAME` set to your EC2 key pair name.

## GitHub Secrets Required

- `AWS_ROLE_ARN`: IAM role ARN with trust relationship for GitHub Actions OIDC.
- `EC2_KEY_PAIR_NAME`: EC2 key pair name used for the Ubuntu instance.

## Optional GitHub Secrets

- `AWS_REGION`: if you want to override the default AWS region (`eu-west-2`).

## AWS IAM Role Requirements

The GitHub OIDC role should have a trust policy for GitHub Actions and a minimum permission policy such as the example below.

### Example Trust Policy

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

### Example IAM Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "ec2:CreateSecurityGroup",
        "ec2:CreateKeyPair",
        "ec2:DeleteSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:RunInstances",
        "ec2:TerminateInstances",
        "ec2:StopInstances",
        "ec2:StartInstances",
        "ec2:TerminateInstances",
        "ec2:CreateVolume",
        "ec2:DeleteVolume",
        "ec2:AttachVolume",
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeRouteTables",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeImages",
        "ec2:ModifyInstanceAttribute",
        "ec2:DeleteSecurityGroup",
        "iam:ListInstanceProfiles",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
```

> Note: For a demo, a broad policy can be acceptable, but for production you should tighten IAM permissions further.

## Deployment Steps

1. Clone the repository.
2. Update `terraform/terraform.tfvars`:
   - Set `key_pair_name` to your EC2 key pair.
   - Optionally restrict `allowed_ssh_cidr` to your public IP.
3. Run locally for validation:

```bash
cd terraform
terraform init
terraform fmt -check -recursive
terraform validate
```

4. Push the repository to GitHub.
5. Create a pull request or push to a feature branch to run the CI workflow (`.github/workflows/ci.yml`).
6. Merge into `main` to trigger the CD workflow (`.github/workflows/cd.yml`).

> GitHub Actions caches the local Terraform state file and `.terraform` folder for the main branch so the demo can track deployed resources without a remote backend.

## Local Deployment Commands

```bash
cd terraform
terraform init
terraform plan -var="key_pair_name=<your-key-pair-name>"
terraform apply -auto-approve -var="key_pair_name=<your-key-pair-name>"
```

## Validation

- Confirm Terraform plan and apply succeed.
- Access the website via the EC2 public IP output from Terraform.
- Confirm the page shows:
  - `Hello, Welcome to Capgemini Invent`
  - `Version: v1.0`
  - `Environment: Dev`
- Confirm GitHub Actions completed successfully.

## Clean Up

1. Open the GitHub Actions tab.
2. Run the `Destroy — Terraform Infrastructure Cleanup` workflow.
3. Enter `DESTROY` to confirm.

## Architecture Summary

- GitHub Actions CI validates Terraform and runs a security scan.
- GitHub Actions CD uses AWS OIDC to authenticate without long-lived AWS credentials.
- Terraform provisions:
  - VPC, public subnet, internet gateway, route table
  - Security group allowing SSH and HTTP
  - Ubuntu EC2 instance
- EC2 User Data installs Nginx and deploys the static website to `/var/www/html`.
- The destroy workflow safely removes all Terraform-managed infrastructure.

## Troubleshooting

- If Terraform format fails, run `terraform fmt -recursive`.
- If Terraform validate fails, inspect the output and fix syntax or variables.
- If the website does not load:
  - Confirm the EC2 instance is in a public subnet.
  - Confirm the security group allows port 80.
  - Confirm EC2 user data executed successfully by checking `/var/log/userdata.log` on the instance.
- If AWS OIDC fails, verify the `AWS_ROLE_ARN` secret and IAM trust policy.
- Use `terraform destroy -auto-approve -var="key_pair_name=<your-key-pair-name>"` for local cleanup if needed.

## Expected Output

After successful deployment, the website should appear at `http://<EC2_PUBLIC_IP>` and display the demo content with header, footer, version, and environment values.
