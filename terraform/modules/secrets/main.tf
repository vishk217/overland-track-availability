resource "aws_secretsmanager_secret" "stripe_keys" {
  name        = "overland/stripe-keys"
  description = "Stripe API keys for payment processing"
}

resource "aws_secretsmanager_secret_version" "stripe_keys" {
  secret_id = aws_secretsmanager_secret.stripe_keys.id
  secret_string = jsonencode({
    publishable_key = var.stripe_publishable_key
    secret_key      = var.stripe_secret_key
    webhook_secret  = var.stripe_webhook_secret
  })
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name        = "overland/jwt-secret"
  description = "JWT signing secret"
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id = aws_secretsmanager_secret.jwt_secret.id
  secret_string = jsonencode({
    secret = var.jwt_secret
  })
}