resource "aws_s3_bucket" "overland_data" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "overland_data" {
  bucket = aws_s3_bucket.overland_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "overland_data" {
  bucket = aws_s3_bucket.overland_data.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowFrontendAccess"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.overland_data.arn}/*"
        Condition = {
          StringLike = {
            "aws:Referer" = [
              "https://${var.frontend_bucket_name}/*",
              "https://${var.frontend_bucket_name}.s3-website-ap-southeast-2.amazonaws.com/*"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_cors_configuration" "overland_data" {
  bucket = aws_s3_bucket.overland_data.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = [
      "https://${var.frontend_bucket_name}.s3-website-ap-southeast-2.amazonaws.com"
    ]
    max_age_seconds = 3000
  }
}