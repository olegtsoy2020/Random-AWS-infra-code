provider "aws" {
  region = "eu-west-1" # You can change this to your preferred AWS region
}

resource "aws_s3_bucket" "my_website" {
  bucket = "my-unique-bucket-name" # Make sure this is globally unique
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_ses_domain_identity" "my_domain" {
  domain = "mydomain.com" # Replace with your domain
}

resource "aws_ses_domain_identity_verification" "my_domain_verify" {
  domain = aws_ses_domain_identity.my_domain.domain

  depends_on = [
    aws_ses_domain_identity.my_domain,
  ]
}

output "s3_bucket_website_endpoint" {
  value = aws_s3_bucket.my_website.website_endpoint
}

output "ses_domain_identity_arn" {
  value = aws_ses_domain_identity.my_domain.arn
}
