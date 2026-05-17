# ─────────────────────────────────────────────────────────────────────────────
# main.tf
# Provisions an EC2 instance and an S3 bucket on AWS
# Author : Subham Kumar
# ─────────────────────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ── Provider ──────────────────────────────────────────────────────────────────
provider "aws" {
  region = var.aws_region
}

# ─────────────────────────────────────────────────────────────────────────────
# DATA SOURCES
# ─────────────────────────────────────────────────────────────────────────────

# Latest Amazon Linux 2023 AMI (free-tier eligible)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Default VPC — no need to create a custom VPC for this project
data "aws_vpc" "default" {
  default = true
}

# ─────────────────────────────────────────────────────────────────────────────
# SECURITY GROUP
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  # Allow SSH (restrict to your IP in production)
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-sg"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# EC2 INSTANCE
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Install and start Nginx on launch
  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Deployed by Subham Kumar via Terraform</h1>" > /usr/share/nginx/html/index.html
  EOF

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-web-server"
  })
}

# ─────────────────────────────────────────────────────────────────────────────
# S3 BUCKET
# ─────────────────────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "app_bucket" {
  # Bucket names must be globally unique — suffix with a random value
  bucket = "${var.project_name}-bucket-${random_id.suffix.hex}"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-bucket"
  })
}

# Block all public access (security best practice)
resource "aws_s3_bucket_public_access_block" "app_bucket_access" {
  bucket = aws_s3_bucket.app_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning so you can recover overwritten/deleted objects
resource "aws_s3_bucket_versioning" "app_bucket_versioning" {
  bucket = aws_s3_bucket.app_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Random suffix to ensure the S3 bucket name is globally unique
resource "random_id" "suffix" {
  byte_length = 4
}
