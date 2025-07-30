# AWS SES Configuration for Contact Form
# Add this to your existing Terraform configuration

# Variables for email configuration
variable "sender_email" {
  description = "Email address to send from (will be verified in SES)"
  type        = string
  # Example: "noreply@yourdomain.com"
}

variable "recipient_email" {
  description = "Email address to receive contact form submissions"
  type        = string
  # Example: "contact@yourdomain.com"
}

# Verify sender email identity in SES
resource "aws_ses_email_identity" "sender" {
  email = var.sender_email
}

# Verify recipient email identity in SES
resource "aws_ses_email_identity" "recipient" {
  email = var.recipient_email
}

# IAM role for EC2 instance to use SES
resource "aws_iam_role" "ec2_ses_role" {
  name = "ec2-ses-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for SES permissions
resource "aws_iam_policy" "ses_policy" {
  name        = "ses-email-policy"
  description = "Policy for sending emails via SES"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail",
          "ses:GetSendQuota",
          "ses:GetSendStatistics"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ec2_ses_policy_attachment" {
  role       = aws_iam_role.ec2_ses_role.name
  policy_arn = aws_iam_policy.ses_policy.arn
}

# Instance profile for EC2
resource "aws_iam_instance_profile" "ec2_ses_profile" {
  name = "ec2-ses-profile"
  role = aws_iam_role.ec2_ses_role.name
}

# Update your existing EC2 instance to use the instance profile
# Add this to your existing aws_instance resource:
# iam_instance_profile = aws_iam_instance_profile.ec2_ses_profile.name

# Example of how to update your user_data script
locals {
  user_data = templatefile("${path.module}/user_data.sh", {
    sender_email    = var.sender_email
    recipient_email = var.recipient_email
    aws_region      = var.aws_region
  })
}

# Output the verification status (you'll need to manually verify via email)
output "ses_sender_verification" {
  value = "Please check ${var.sender_email} for verification email and click the verification link"
}

output "ses_recipient_verification" {
  value = "Please check ${var.recipient_email} for verification email and click the verification link"
}

# Optional: Configuration for domain-based sending (if you own a domain)
# Uncomment and modify if you want to verify a domain instead of individual emails

# variable "domain_name" {
#   description = "Domain name to verify for SES (optional)"
#   type        = string
#   default     = ""
# }

# resource "aws_ses_domain_identity" "domain" {
#   count  = var.domain_name != "" ? 1 : 0
#   domain = var.domain_name
# }

# resource "aws_route53_record" "ses_verification" {
#   count   = var.domain_name != "" ? 1 : 0
#   zone_id = var.route53_zone_id  # You need to define this variable
#   name    = "_amazonses.${var.domain_name}"
#   type    = "TXT"
#   ttl     = "600"
#   records = [aws_ses_domain_identity.domain[0].verification_token]
# }
