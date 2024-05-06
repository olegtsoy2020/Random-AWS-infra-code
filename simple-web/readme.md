## To use this configuration:

Replace **"your-bucket-name"** with your desired bucket name.

Optionally adjust the region ("**eu-west-1**") to match your desired AWS region.

Save the configuration to a **.tf** file (e.g., **main.tf**).

Initialize Terraform by running **terraform init**.

Apply the configuration by running **terraform apply**.

After applying the configuration, you'll receive the URL of the S3 bucket website endpoint where your static website will be hosted. 
If you've opted for CloudFront, you'll also receive the CloudFront distribution URL for content delivery.
