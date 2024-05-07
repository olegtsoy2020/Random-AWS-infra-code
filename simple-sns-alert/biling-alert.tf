# Configure AWS provider
provider "aws" {
  region = "eu-west-1" # Change as needed
}

# Create SNS topic for billing alerts
resource "aws_sns_topic" "billing_alerts" {
  name = "billing-alerts-topic"
}

# Create SNS topic subscription to send email notifications
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.billing_alerts.arn
  protocol  = "email"
  endpoint  = "youremail@example.com" # Replace with your email
}

# Create CloudWatch billing metric
data "aws_billing_service_account" "main" {}

resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "billing_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 21600
  statistic           = "Maximum"
  threshold           = 500.0
  alarm_description   = "Alarm when the estimated charges exceed $500"
  dimensions = {
    Currency = "USD"
  }

  alarm_actions = [aws_sns_topic.billing_alerts.arn]
}
