resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "frontend-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "frontend" {
  origin {
    domain_name              = var.frontend_bucket_domain_name
    origin_id                = "S3-${var.frontend_bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = var.domain_name

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.frontend_bucket_name}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect_www.arn
    }

    forwarded_values {
      query_string = false
      headers      = ["CloudFront-Viewer-Country", "CloudFront-Viewer-Country-Name", "CloudFront-Viewer-Country-Region", "CloudFront-Viewer-City"]
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  wait_for_deployment = false

}

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "security-headers-policy"

  custom_headers_config {
    items {
      header   = "Content-Type"
      value    = "text/html; charset=utf-8"
      override = false
    }
  }
}

resource "aws_cloudfront_function" "redirect_www" {
  name    = "redirect-www"
  runtime = "cloudfront-js-1.0"
  code    = <<EOF
function handler(event) {
    var request = event.request;
    var host = request.headers.host.value;
    
    if (host.startsWith('www.')) {
        var response = {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                'location': { value: 'https://' + host.substring(4) + request.uri }
            }
        };
        return response;
    }
    
    return request;
}
EOF
}