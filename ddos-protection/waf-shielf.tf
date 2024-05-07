provider "aws" {
  region = "eu-west-1" # Change to your preferred region
}

# Create an S3 bucket for static website hosting
resource "aws_s3_bucket" "static_website" {
  bucket = "my-static-website-bucket" # Choose a unique bucket name

  website {
    index_document = "index.html"
  }
}

# Create a CloudFront distribution for the S3 bucket
resource "aws_cloudfront_distribution" "static_website_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_website.bucket_regional_domain_name
    origin_id   = "s3-static-website"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oid.id
    }
  }

  enabled = true

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-static-website"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Create a CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "oid" {
  comment = "Access identity for static website"
}

# Create a Web Application Firewall (WAF) Web ACL
resource "aws_wafv2_web_acl" "web_acl" {
  name        = "web-acl"
  scope       = "CLOUDFRONT"
  description = "Web ACL to protect against DDoS attacks"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "web-acl-metrics"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "web-acl-metrics"
    sampled_requests_enabled   = true
  }

  tags = {
    Name = "web-acl"
  }
}

# Associate WAF Web ACL with CloudFront distribution
resource "aws_wafv2_web_acl_association" "web_acl_association" {
  resource_arn = aws_cloudfront_distribution.static_website_distribution.arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl.arn
}

# Enable AWS Shield Advanced (for the whole account)
resource "aws_shield_protection" "cloudfront_protection" {
  name      = "cloudfront-protection"
  resource_arn = aws_cloudfront_distribution.static_website_distribution.arn
}
