resource "aws_dynamodb_table" "users" {
  name           = "overland-users"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  hash_key = "user_id"

  global_secondary_index {
    name               = "email-index"
    hash_key           = "email"
    projection_type    = "ALL"
  }

  tags = {
    Name = "overland-users"
  }
}

resource "aws_dynamodb_table" "subscriptions" {
  name           = "overland-subscriptions"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "user_id"
    type = "S"
  }

  hash_key = "user_id"

  tags = {
    Name = "overland-subscriptions"
  }
}

resource "aws_dynamodb_table" "notifications" {
  name           = "overland-notifications"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "notification_id"
    type = "S"
  }

  hash_key  = "user_id"
  range_key = "notification_id"

  tags = {
    Name = "overland-notifications"
  }
}

resource "aws_dynamodb_table" "notification_history" {
  name           = "overland-notification-history"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "sent_at"
    type = "S"
  }

  hash_key  = "user_id"
  range_key = "sent_at"

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }

  tags = {
    Name = "overland-notification-history"
  }
}