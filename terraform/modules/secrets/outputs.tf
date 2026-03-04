output "stripe_keys_arn" {
  value = aws_secretsmanager_secret.stripe_keys.arn
}

output "jwt_secret_arn" {
  value = aws_secretsmanager_secret.jwt_secret.arn
}