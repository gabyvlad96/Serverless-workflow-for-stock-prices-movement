locals {
  s3_origin_id = "myS3Origin"
}

data "aws_acm_certificate" "issued" {
  domain   = "www.aws-gabriel.de"
  statuses = ["ISSUED"]
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "www.aws-gabriel.de OAI"
}

resource "aws_cloudfront_distribution" "cf_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_react_bucket.bucket_regional_domain_name
    origin_id   = "myS3Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "cf_distribution"
  default_root_object = "index.html"

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn = data.aws_acm_certificate.issued.arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version  = "TLSv1"
  }

  aliases = ["www.aws-gabriel.de"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    path_pattern     = "/index.html"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = "production"
  }
}
