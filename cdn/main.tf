resource "aws_s3_bucket" "origin_static" {
  bucket = "${var.domain}"
  acl = "public-read"
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"PublicReadForGetBucketObjects",
        "Effect":"Allow",
      "Principal": "*",
      "Action":"s3:GetObject",
      "Resource":["arn:aws:s3:::${var.domain}/*"
      ]
    }
  ]
}
POLICY
  force_destroy = true
  website {
    index_document = "index.html"
  }
}

resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = "${var.domain}.s3.amazonaws.com"
    origin_id   = "static"
  }
  enabled = true
  default_root_object = "index.html"
  aliases = ["${var.domain}"]
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "static"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
    viewer_protocol_policy = "allow-all"
  }
  // fallback for SPA
  custom_error_response {
    error_code = 404
    error_caching_min_ttl = 60
    response_code = 200
    response_page_path = "/index.html"
  }
  price_class = "PriceClass_200"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = "${var.certificate_arn}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}