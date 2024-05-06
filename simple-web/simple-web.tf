# Define provider
provider "aws" {
  region = "eu-west-1" # Update with your desired AWS region
}

# Define variables
variable "bucket_name" {
  description = "The name for the S3 bucket"
  default     = "your-bucket-name" # Update with your desired bucket name
}

# Create S3 bucket for hosting the website
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
  acl    = "public-read" # Make objects publicly accessible

  website {
    index_document = "index.html" # Default index document
    error_document = "error.html" # Default error document
  }
}

# Optionally create CloudFront distribution for CDN
resource "aws_cloudfront_distribution" "cdn_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.website_endpoint
    origin_id   = "S3-${var.bucket_name}"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id = "S3-${var.bucket_name}"

    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Output S3 bucket website endpoint URL
output "website_url" {
  value = aws_s3_bucket.website_bucket.website_endpoint
}
