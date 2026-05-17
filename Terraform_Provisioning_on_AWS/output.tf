# ─────────────────────────────────────────────────────────────────────────────
# outputs.tf
# Values printed to terminal after `terraform apply`
# These are also useful for piping into other tools (Ansible, scripts, etc.)
# ─────────────────────────────────────────────────────────────────────────────

output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.web_server.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance — open in browser to see Nginx"
  value       = aws_instance.web_server.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.web_server.public_dns
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket (includes random suffix)"
  value       = aws_s3_bucket.app_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.app_bucket.arn
}

output "aws_region" {
  description = "Region where resources were deployed"
  value       = var.aws_region
}
