# Terraform Resources

This document lists all AWS resources created by the Terraform configuration.

**Last Updated**: May 13, 2026

---

## Data Sources

| Resource Type | Terraform ID | Description |
|---|---|---|
| `aws_ami` | `ubuntu` | Fetches the latest Ubuntu 22.04 LTS AMI from Canonical |

---

## Network Resources

### VPC & Subnetting
| Resource Type | Terraform ID | Description | CIDR/Config |
|---|---|---|---|
| `aws_vpc` | `main` | Virtual Private Cloud | 10.0.0.0/16 |
| `aws_subnet` | `public` | Public subnet for EC2 instance | 10.0.1.0/24 |
| `aws_internet_gateway` | `igw` | Internet gateway for VPC public connectivity | Attached to VPC |

### Routing
| Resource Type | Terraform ID | Description | Config |
|---|---|---|---|
| `aws_route_table` | `public` | Route table for public subnet | Routes 0.0.0.0/0 → IGW |
| `aws_route_table_association` | `public` | Associates public subnet to route table | Links subnet to RT |

---

## Security Resources

| Resource Type | Terraform ID | Description | Rules |
|---|---|---|---|
| `aws_security_group` | `web` | Security group for EC2 web server | **Ingress**: HTTP (80), SSH (22) **Egress**: DNS (53 TCP/UDP), HTTP (80), HTTPS (443) |

---

## Compute Resources

| Resource Type | Terraform ID | Instance Type | Config |
|---|---|---|---|
| `aws_instance` | `web` | Ubuntu 22.04 LTS (t2.micro) | **KeyName**: var.key_pair_name **Subnet**: public subnet **SecurityGroup**: web-sg **IAM**: None **Monitoring**: Enhanced **EBS**: gp3 (8GB encrypted) **UserData**: userdata.sh **IMDSv2**: Required **EBS Optimized**: Yes |

---

## Summary

| Resource Category | Count | Details |
|---|---|---|
| **VPC & Networking** | 5 | 1 VPC, 1 Subnet, 1 IGW, 1 Route Table, 1 Route Table Association |
| **Security** | 1 | 1 Security Group (HTTP 80 + SSH 22 ingress, DNS + HTTP + HTTPS egress) |
| **Compute** | 1 | 1 EC2 Instance (t2.micro, Ubuntu 22.04, no IAM role) |
| **Data Sources** | 1 | 1 AMI data source (latest Ubuntu 22.04) |
| **TOTAL** | **8** | Full infrastructure for web server on AWS |

---

## Resource Naming Convention

All resources are tagged with:
- **Project**: `capgemini-demo`
- **Environment**: `Dev`
- **ManagedBy**: `Terraform`

Names follow pattern: `{project_name}-{resource_type}`
- Example: `capgemini-demo-vpc`, `capgemini-demo-web-sg`, `capgemini-demo-web-server`

---

## Outputs

The following outputs are exported after `terraform apply`:

| Output | Value | Usage |
|---|---|---|
| `ec2_public_ip` | EC2 public IPv4 address | For SSH/HTTP access |
| `website_url` | `http://{public_ip}` | For testing website in browser |
| `instance_id` | EC2 instance ID | For AWS API queries |
| `vpc_id` | VPC resource ID | For reference in other configs |
| `ssh_command` | Full SSH command | Ready-to-paste SSH command |

---

## Cost Estimate (us-east-1)

| Resource | Free Tier | Estimated Cost |
|---|---|---|
| t2.micro EC2 | 750 hours/month | $0 (free tier) |
| 8 GB gp3 EBS | 30 GB/month | $0.80/month |
| Data Transfer | 1 GB/month free | $0 (minimal egress) |
| **TOTAL** | | **~$0.80/month** |

---

## Terraform State

- **State Location**: Local file (`terraform.tfstate`)
- **Backup**: `.tfstate.backup` (auto-generated)
- **Locking**: Not enabled (single-user demo)
- **Remote Backend**: Not configured

> ⚠️ **Note**: For production, use S3 remote backend with state locking via DynamoDB.

---

## Checkov Security Skips

The following Checkov checks are intentionally skipped for this demo:

| Check ID | Description | Reason |
|---|---|---|
| CKV2_AWS_11 | VPC Flow Logs not enabled | Not required for demo |
| CKV2_AWS_12 | Default security group not managed | Not required for demo |
| CKV2_AWS_130 | Public subnet created | Required for demo EC2 |
| CKV2_AWS_24 | EC2 has public IP | Required for HTTP access |
| CKV2_AWS_260 | Security group allows public HTTP | Required for website |
| CKV2_AWS_41 | EC2 lacks IAM instance profile | Not required for demo |

---

## Deployment Variables (terraform.tfvars)

```hcl
aws_region          = "us-east-1"
environment         = "Dev"
project_name        = "capgemini-demo"
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
instance_type       = "t2.micro"
allowed_ssh_cidr    = "0.0.0.0/0"
key_pair_name       = "YOUR_KEY_PAIR_NAME"  # MUST be set by user
```

---

## Related Files

- **Configuration**: `terraform/main.tf`
- **Variables**: `terraform/variables.tf`
- **Outputs**: `terraform/outputs.tf`
- **Provider**: `terraform/provider.tf`
- **Values**: `terraform/terraform.tfvars`
- **Bootstrap**: `terraform/userdata.sh`
