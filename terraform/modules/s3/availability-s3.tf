resource "aws_s3_bucket" "overland_data" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "overland_data" {
  bucket = aws_s3_bucket.overland_data.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "overland_data" {
  bucket = aws_s3_bucket.overland_data.id
  depends_on = [aws_s3_bucket_public_access_block.overland_data]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPublicAccess"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.overland_data.arn}/*"
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