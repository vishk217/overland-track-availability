resource "aws_secretsmanager_secret" "app_secrets" {
  name        = "overland/app-secrets"
  description = "Application secrets including Stripe keys and JWT secret"
}