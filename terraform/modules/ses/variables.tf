variable "domain_name" {
  description = "Domain name for SES identity"
  type        = string
}

variable "aws_region" {
  description = "AWS region for SES MAIL FROM MX record"
  type        = string
}
