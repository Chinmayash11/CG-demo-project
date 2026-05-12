output "ec2_public_ip" {
  description = "Public IP address of the web server"
  value       = aws_instance.web.public_ip
}

output "website_url" {
  description = "URL to access the deployed website"
  value       = "http://${aws_instance.web.public_ip}"
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ubuntu@${aws_instance.web.public_ip}"
}
