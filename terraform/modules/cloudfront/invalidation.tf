resource "aws_cloudfront_invalidation" "frontend" {
  distribution_id = aws_cloudfront_distribution.frontend.id
  paths           = ["/*"]
}