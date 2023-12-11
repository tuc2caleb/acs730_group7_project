

terraform {
  backend "s3" {
    bucket = "acs-730-assignment"               // Bucket where to SAVE Terraform State. Please provide your custom unique name
    key    = "dev/webservers/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                        // Region where bucket is created
  }
}