# ─────────────────────────────────────────────────────────────────────────────
# variables.tf
# All input variables for the project — change values in terraform.tfvars
# ─────────────────────────────────────────────────────────────────────────────

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1"   # Mumbai — closest to Ranchi
}

variable "project_name" {
  description = "Prefix used for naming all resources"
  type        = string
  default     = "subham-devops"
}

variable "instance_type" {
  description = "EC2 instance type (t2.micro is free-tier eligible)"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro", "t3.small"], var.instance_type)
    error_message = "Instance type must be t2.micro, t3.micro, or t3.small."
  }
}

variable "common_tags" {
  description = "Tags applied to every resource for cost tracking and organisation"
  type        = map(string)
  default = {
    Project     = "subham-devops"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Owner       = "Subham Kumar"
  }
}
