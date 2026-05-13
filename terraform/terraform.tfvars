# ── Required: fill these in before running terraform apply ────────────────────
key_pair_name = "your-key-pair-name" # Name of your existing EC2 Key Pair

# ── Optional overrides ────────────────────────────────────────────────────────
aws_region         = "us-east-1"
environment        = "Dev"
project_name       = "capgemini-demo"
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"
instance_type      = "t2.micro"

# !! Restrict this to your own IP for real deployments !!
# e.g. allowed_ssh_cidr = "203.0.113.5/32"
allowed_ssh_cidr = "0.0.0.0/0"
