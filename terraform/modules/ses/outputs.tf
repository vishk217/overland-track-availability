output "domain_identity_arn" {
  value = aws_ses_domain_identity.main.arn
}

output "verification_token" {
  description = "TXT record value to add in Namecheap for domain verification"
  value       = aws_ses_domain_identity.main.verification_token
}

output "dkim_tokens" {
  description = "CNAME records to add in Namecheap for DKIM verification"
  value       = aws_ses_domain_dkim.main.dkim_tokens
}

output "mail_from_domain" {
  description = "MAIL FROM domain - requires MX and SPF records in Namecheap"
  value       = aws_ses_domain_mail_from.main.mail_from_domain
}
